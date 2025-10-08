package com.tapp.so.adjust

import android.content.Context
import android.util.Log
import com.adjust.sdk.AdjustEvent
import com.adjust.sdk.AdjustPurchaseVerificationResult
import com.adjust.sdk.GooglePlayInstallReferrerDetails
import com.adjust.sdk.OnGooglePlayInstallReferrerReadListener
import com.adjust.sdk.OnIsEnabledListener
import com.adjust.sdk.OnPurchaseVerificationFinishedListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

// ------- Tapp SDK (your native lib) -------
import com.example.tapp.Tapp
import com.example.tapp.models.Environment
import com.example.tapp.models.Affiliate
import com.example.tapp.services.network.RequestModels
import com.example.tapp.services.affiliate.tapp.DeferredLinkDelegate

/** ComTappSoAdjustPlugin */
class ComTappSoAdjustPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

  companion object {
    private const val TAG = "ComTappSoAdjustPlugin"
    private const val METHOD_CHANNEL = "com.tapp.so.adjust/methods"
    private const val EVENT_CHANNEL  = "com.tapp.so.adjust/events"
  }

  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context

  // Single Tapp instance
  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
  private var eventSink: EventChannel.EventSink? = null
  private lateinit var tapp: Tapp

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(TAG, "onAttachedToEngine")
    context = binding.applicationContext
    tapp = Tapp(context)

    methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
    methodChannel.setMethodCallHandler(this)

    eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(args: Any?, sink: EventChannel.EventSink) {
        Log.d(TAG, "EventChannel.onListen args=$args")
        eventSink = sink

        // Wire native deferred link callbacks to Flutter stream
        tapp.deferredLinkDelegate = object : DeferredLinkDelegate {
          override fun didReceiveDeferredLink(resp: RequestModels.TappLinkDataResponse) {
            Log.d(TAG, "didReceiveDeferredLink → $resp")
            sink.success(
              mapOf(
                "type"           to "onDeferredLinkReceived",
                "error"          to resp.error,
                "message"        to resp.message,
                "tappUrl"        to resp.tappUrl,
                "attrTappUrl"    to resp.attrTappUrl,
                "influencer"     to resp.influencer,
                "isFirstSession" to (resp.isFirstSession ?: false),
                "data"           to (resp.data ?: emptyMap<String, String>())
              )
            )
          }

          override fun didFailResolvingUrl(resp: RequestModels.FailResolvingUrlResponse) {
            Log.d(TAG, "didFailResolvingUrl → $resp")
            sink.success(
              mapOf(
                "type"  to "onDidFailResolvingURL",
                "url"   to resp.url,
                "error" to resp.error
              )
            )
          }

          override fun testListener(test: String) {
            sink.success(mapOf("type" to "onTestListener", "test" to test))
          }
        }
      }

      override fun onCancel(args: Any?) {
        Log.d(TAG, "EventChannel.onCancel args=$args")
        eventSink = null
        tapp.deferredLinkDelegate = null
      }
    })
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "onMethodCall: ${call.method} ← ${call.arguments}")
    when (call.method) {
      "initialize"          -> initialize(call, result)
      "getPlatformVersion"  -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "shouldProcess"       -> {
        val url = call.argument<String>("deepLink")
        Log.d(TAG, "shouldProcess(deepLink=$url)")
        result.success(tapp.shouldProcess(url))
      }
      "generateUrl"         -> generateUrl(call, result)
      "handleEvent"         -> {
        Log.d(TAG, "handleEvent(token=${call.argument<String>("eventToken")})")
        tapp.handleEvent(call.argument<String>("eventToken")!!)
        result.success(null)
      }
      "handleTappEvent"     -> handleTappEvent(call, result)
      "fetchLinkData"       -> fetchLinkData(call, result)
      "fetchOriginLinkData" -> fetchOriginLinkData(result)
      "getConfig"           -> {
        Log.d(TAG, "getConfig()")
        val response = tapp.getConfig()
        Log.d(TAG, "getConfig raw → $response")
        result.success(response.toMap())
      }
      "simulateTestEvent"   -> { tapp.simulateTestEvent(); result.success(null) }

      // —— Adjust integration ——
      "adjustEnable"         -> { tapp.adjustEnable(); result.success(null) }
      "adjustDisable"        -> { tapp.adjustDisable(); result.success(null) }
      "adjustIsEnabled"      -> adjustIsEnabled(result)
      "adjustGdprForgetMe"   -> { tapp.adjustGdprForgetMe(); result.success(null) }
      "adjustSetReferrer"    -> { tapp.adjustSetReferrer(call.argument<String>("referrer")!!); result.success(null) }
      "adjustSetPushToken"   -> { tapp.adjustSetPushToken(call.argument<String>("token")!!); result.success(null) }
      "adjustOnResume"       -> { tapp.adjustOnResume(); result.success(null) }
      "adjustOnPause"        -> { tapp.adjustOnPause(); result.success(null) }

      "adjustTrackAdRevenue"          -> trackAdRevenue(call, result)
      "adjustTrackThirdPartySharing"  -> { tapp.adjustTrackThirdPartySharing(call.argument<Boolean>("enabled")!!); result.success(null) }
      "adjustTrackMeasurementConsent" -> { tapp.adjustTrackMeasurementConsent(call.argument<Boolean>("consent")!!); result.success(null) }

      "adjustAddGlobalCallbackParameter"     -> { tapp.adjustAddGlobalCallbackParameter(call.argument<String>("key")!!, call.argument<String>("value")!!); result.success(null) }
      "adjustAddGlobalPartnerParameter"      -> { tapp.adjustAddGlobalPartnerParameter(call.argument<String>("key")!!, call.argument<String>("value")!!); result.success(null) }
      "adjustRemoveGlobalCallbackParameter"  -> { tapp.adjustRemoveGlobalCallbackParameter(call.argument<String>("key")!!); result.success(null) }
      "adjustRemoveGlobalPartnerParameter"   -> { tapp.adjustRemoveGlobalPartnerParameter(call.argument<String>("key")!!); result.success(null) }
      "adjustRemoveGlobalCallbackParameters" -> { tapp.adjustRemoveGlobalCallbackParameters(); result.success(null) }
      "adjustRemoveGlobalPartnerParameters"  -> { tapp.adjustRemoveGlobalPartnerParameters(); result.success(null) }

      "adjustVerifyAppStorePurchase"          -> verifyAppStorePurchase(call, result)
      "adjustVerifyAndTrackPlayStorePurchase" -> adjustVerifyAndTrackPlayStorePurchase(call, result)
      "adjustTrackPlayStoreSubscription"      -> trackPlayStoreSubscription(call, result)

      "adjustGetAdid"                      -> getAsync { tapp.adjustGetAdid(it) }.toPromise(result)
      "adjustGetIdfa"                      -> getAsync { tapp.adjustGetIdfa(it) }.toPromise(result)
      "adjustGetGoogleAdId"                -> getAsync { tapp.adjustGetGoogleAdId(it) }.toPromise(result)
      "adjustGetAmazonAdId"                -> getAsync { tapp.adjustGetAmazonAdId(it) }.toPromise(result)
      "adjustGetSdkVersion"                -> getAsync { tapp.adjustGetSdkVersion(it) }.toPromise(result)
      "adjustGetGooglePlayInstallReferrer" -> getReferrer(result)

      else -> {
        Log.w(TAG, "Method not implemented: ${call.method}")
        result.notImplemented()
      }
    }
  }

  // — Helpers —

  private fun initialize(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "initialize() args=${call.arguments}")
    val args      = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
    val auth      = args["authToken"]   as? String ?: ""
    val envStr    = args["environment"] as? String ?: "SANDBOX"
    val tappToken = args["tappToken"]   as? String ?: ""

    val env = if (envStr.equals("PRODUCTION", true) || envStr.equals("PROD", true))
      Environment.PRODUCTION else Environment.SANDBOX

    val aff = Affiliate.ADJUST

    tapp.start(com.example.tapp.utils.TappConfiguration(auth, env, tappToken, aff))
    Log.d(TAG, "initialize() complete")
    result.success(null)
  }

  private fun generateUrl(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "generateUrl() args=${call.arguments}")
    val influencer = call.argument<String>("influencer")
      ?: return result.error("BAD_ARGS", "Missing influencer", null)
    val adGroup  = call.argument<String>("adGroup")
    val creative = call.argument<String>("creative")
    val data     = (call.argument<Map<String, String>>("data") ?: emptyMap())

    scope.launch {
      try {
        val resp = tapp.url(influencer, adGroup, creative, data)
        Log.d(TAG, "generateUrl() resp=$resp")
        withContext(Dispatchers.Main) { result.success(resp.influencer_url) }
      } catch (e: Exception) {
        Log.e(TAG, "generateUrl() error", e)
        withContext(Dispatchers.Main) { result.error("URL_ERROR", e.message, null) }
      }
    }
  }

  private fun handleTappEvent(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "handleTappEvent() args=${call.arguments}")
    val actionStr = call.argument<String>("eventAction")?.lowercase()
      ?: return result.error("BAD_ARGS", "Missing eventAction", null)

    scope.launch {
      tapp.handleTappEvent(RequestModels.TappEvent(RequestModels.EventAction.custom(actionStr)))
      Log.d(TAG, "handleTappEvent() complete")
      withContext(Dispatchers.Main) { result.success(null) }
    }
  }

  private fun fetchLinkData(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "fetchLinkData() args=${call.arguments}")
    val url = call.argument<String>("deepLink")
      ?: return result.error("BAD_ARGS", "Missing URL", null)

    scope.launch {
      val resp = tapp.fetchLinkData(url)
      Log.d(TAG, "fetchLinkData() resp=$resp")
      val map = resp?.let {
        mapOf(
          "error"          to it.error,
          "message"        to it.message,
          "tappUrl"        to it.tappUrl,
          "attrTappUrl"    to it.attrTappUrl,
          "influencer"     to it.influencer,
          "isFirstSession" to (it.isFirstSession ?: false),
          "data"           to (it.data ?: emptyMap<String, String>())
        )
      } ?: mapOf("error" to true, "message" to "no response")
      withContext(Dispatchers.Main) { result.success(map) }
    }
  }

  private fun fetchOriginLinkData(result: MethodChannel.Result) {
    Log.d(TAG, "fetchOriginLinkData()")
    scope.launch {
      val resp = tapp.fetchOriginalLinkData()
      Log.d(TAG, "fetchOriginLinkData() resp=$resp")
      val map = resp?.let {
        mapOf(
          "error"          to it.error,
          "message"        to it.message,
          "tappUrl"        to it.tappUrl,
          "attrTappUrl"    to it.attrTappUrl,
          "influencer"     to it.influencer,
          "isFirstSession" to (it.isFirstSession ?: false),
          "data"           to (it.data ?: emptyMap<String, String>())
        )
      } ?: mapOf("error" to true, "message" to "no response")
      withContext(Dispatchers.Main) { result.success(map) }
    }
  }

  private fun trackAdRevenue(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "trackAdRevenue() args=${call.arguments}")
    tapp.adjustTrackAdRevenue(
      call.argument<String>("source")!!,
      call.argument<Double>("revenue")!!,
      call.argument<String>("currency")!!
    )
    result.success(null)
  }

  private fun adjustIsEnabled(result: MethodChannel.Result) {
    Log.d(TAG, "adjustIsEnabled()")
    tapp.adjustIsEnabled(context, object : OnIsEnabledListener {
      override fun onIsEnabledRead(isEnabled: Boolean) {
        Log.d(TAG, "adjustIsEnabled callback → $isEnabled")
        result.success(isEnabled)
      }
    })
  }

  private fun verifyAppStorePurchase(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "verifyAppStorePurchase() args=${call.arguments}")
    val txId = call.argument<String>("transactionId")!!
    val pid  = call.argument<String>("productId")!!
    tapp.adjustVerifyAppStorePurchase(txId, pid) { res ->
      Log.d(TAG, "verifyAppStorePurchase callback → $res")
      result.success(
        mapOf(
          "verificationStatus" to res.verificationStatus,
          "code"               to res.code,
          "message"            to res.message
        )
      )
    }
  }

  private fun adjustVerifyAndTrackPlayStorePurchase(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "adjustVerifyAndTrackPlayStorePurchase() args=${call.arguments}")
    val token = call.argument<String>("eventToken")!!
    val event = AdjustEvent(token)
    tapp.adjustVerifyAndTrackPlayStorePurchase(event, object : OnPurchaseVerificationFinishedListener {
      override fun onVerificationFinished(res: AdjustPurchaseVerificationResult) {
        Log.d(TAG, "adjustVerifyAndTrackPlayStorePurchase callback → $res")
        result.success(
          mapOf(
            "verificationStatus" to res.verificationStatus,
            "code"               to res.code,
            "message"            to res.message
          )
        )
      }
    })
  }

  private fun trackPlayStoreSubscription(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "trackPlayStoreSubscription() args=${call.arguments}")
    val sub = call.argument<Map<String, Any>>("subscription")!!
    tapp.adjustTrackPlayStoreSubscription(
      sub["price"] as Long,
      sub["currency"] as String,
      sub["sku"] as String,
      sub["orderId"] as String,
      sub["signature"] as String,
      sub["purchaseToken"] as String,
      sub["purchaseTime"] as? Long
    )
    result.success(null)
  }

  private fun getReferrer(result: MethodChannel.Result) {
    Log.d(TAG, "getReferrer()")
    tapp.adjustGetGooglePlayInstallReferrer(object : OnGooglePlayInstallReferrerReadListener {
      override fun onInstallReferrerRead(details: GooglePlayInstallReferrerDetails?) {
        Log.d(TAG, "getReferrer callback → $details")
        result.success(details?.toString() ?: "")
      }

      override fun onFail(msg: String?) {
        Log.e(TAG, "getReferrer error → $msg")
        result.error("INSTALL_REFERRER_ERROR", msg, null)
      }
    })
  }

  // Utility to wrap async callbacks into a one-shot promise
  private fun <T> getAsync(callee: ((T?) -> Unit) -> Unit) = object {
    fun toPromise(result: MethodChannel.Result) {
      callee.invoke { v ->
        if (v != null) result.success(v) else result.error("NULL", "No value", null)
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(TAG, "onDetachedFromEngine")
    scope.cancel()
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  // Convert ConfigResponse → Map
  private fun RequestModels.ConfigResponse.toMap() = mapOf(
    "error"   to this.error,
    "message" to this.message,
    "config"  to (this.config?.let {
      mapOf(
        "authToken"   to it.authToken,
        "env"         to it.env.name,
        "tappToken"   to it.tappToken,
        "affiliate"   to it.affiliate.name,
        "bundleID"    to (it.bundleID ?: ""),
        "appToken"    to (it.appToken ?: ""),
        "deepLinkUrl" to (it.deepLinkUrl ?: ""),
        "linkToken"   to (it.linkToken ?: "")
      )
    } ?: emptyMap<String, Any>())
  )
}
