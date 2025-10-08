import Flutter
import UIKit
import TappAdjust
import Tapp

public class ComTappSoAdjustPlugin: NSObject, FlutterPlugin {

  private var methodChannel: FlutterMethodChannel!
  private var eventChannel: FlutterEventChannel!
  private var eventSink: FlutterEventSink?

  // MARK: - Registration

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ComTappSoAdjustPlugin()

    // Method channel
    instance.methodChannel = FlutterMethodChannel(
      name: "com.tapp.so.adjust/methods",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)

    // Event channel for deferred-link callbacks
    instance.eventChannel = FlutterEventChannel(
      name: "com.tapp.so.adjust/events",
      binaryMessenger: registrar.messenger()
    )
    instance.eventChannel.setStreamHandler(instance)
  }

  // MARK: - MethodChannel

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]

    switch call.method {
    // ---- Core SDK ----

    case "initialize":
      guard
        let auth      = args?["authToken"]   as? String,
        let envStr    = args?["environment"] as? String,
        let tappToken = args?["tappToken"]   as? String
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing initialize args", details: nil))
        return
      }
      let bundleID = Bundle.main.bundleIdentifier ?? ""
      let config = TappConfiguration(
        authToken: auth,
        env: envStr,                  // string-based initializer (e.g., "PRODUCTION"/"SANDBOX")
        tappToken: tappToken,
        affiliateName: "adjust",     // e.g., "adjust"
        bundleID: bundleID
      )
      Tapp.start(config: config, delegate: self)
      result(nil)

    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "shouldProcess":
      guard
        let link = args?["deepLink"] as? String,
        let url  = URL(string: link)
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Expected deepLink string", details: nil))
        return
      }
      result(Tapp.shouldProcess(url: url))

    case "generateUrl":
      guard let influencer = args?["influencer"] as? String else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing influencer", details: nil))
        return
      }
      let adGroup  = args?["adGroup"]  as? String
      let creative = args?["creative"] as? String
      let data     = args?["data"]     as? [String: String]
      let urlConfig = AffiliateURLConfiguration(
        influencer: influencer,
        adgroup: adGroup,
        creative: creative,
        data: data
      )
      Tapp.url(config: urlConfig) { response, error in
        if let err = error {
          result(FlutterError(code: "URL_ERROR", message: err.localizedDescription, details: nil))
        } else if let resp = response {
          result(resp.url.absoluteString)
        } else {
          result(FlutterError(code: "URL_ERROR", message: "Unexpected nil response", details: nil))
        }
      }

    case "handleEvent":
      guard let token = args?["eventToken"] as? String else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing eventToken", details: nil))
        return
      }
      let cfg = EventConfig(eventToken: token)
      Tapp.handleEvent(config: cfg)
      result(nil)

    case "handleTappEvent":
      guard let action = args?["eventAction"] as? String else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing eventAction", details: nil))
        return
      }
      let event = TappEvent(eventActionName: action)
      Tapp.handleTappEvent(event: event)
      result(nil)

    case "fetchLinkData":
      guard
        let link = args?["deepLink"] as? String,
        let url  = URL(string: link)
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Expected deepLink", details: nil))
        return
      }
      Tapp.fetchLinkData(for: url) { data, error in
        if let err = error {
          result([
            "error": true,
            "message": err.localizedDescription
          ])
        } else if let d = data {
          result([
            "error": false,
            "message": "",
            "tappUrl": d.tappURL.absoluteString,
            "attrTappUrl": d.attributedTappURL.absoluteString,
            "influencer": d.influencer,
            "isFirstSession": d.isFirstSession,
            "data": d.data ?? [:]
          ])
        } else {
          result([
            "error": true,
            "message": "Unknown error"
          ])
        }
      }

    case "fetchOriginLinkData":
      Tapp.fetchOriginLinkData { data, error in
        if let err = error {
          result([
            "error": true,
            "message": err.localizedDescription
          ])
        } else if let d = data {
          result([
            "error": false,
            "message": "",
            "tappUrl": d.tappURL.absoluteString,
            "attrTappUrl": d.attributedTappURL.absoluteString,
            "influencer": d.influencer,
            "isFirstSession": d.isFirstSession,
            "data": d.data ?? [:]
          ])
        } else {
          result([
            "error": true,
            "message": "Unknown error"
          ])
        }
      }

    case "getConfig":
      // iOS: not supported
      print("[com_tapp_so_adjust] getConfig not supported on iOS")
      result([
        "error": true,
        "message": "getConfig not supported on iOS"
      ])

    // ---- Adjust integration ----

    case "adjustEnable":
      Tapp.adjustEnable(); result(nil)

    case "adjustDisable":
      Tapp.adjustDisable(); result(nil)

    case "adjustIsEnabled":
      Tapp.adjustIsEnabled { num in result(num.boolValue) }

    case "adjustGdprForgetMe":
      Tapp.adjustGdprForgetMe(); result(nil)

    case "adjustSetReferrer":
      // Not supported on iOS
      print("[com_tapp_so_adjust] adjustSetReferrer not supported on iOS")
      result([
        "error": true,
        "message": "adjustSetReferrer not supported on iOS"
      ])

    case "adjustSetPushToken":
      // Not supported on iOS
      print("[com_tapp_so_adjust] adjustSetPushToken not supported on iOS")
      result([
        "error": true,
        "message": "adjustSetPushToken not supported on iOS"
      ])

    case "adjustTrackAdRevenue":
      if
        let src = args?["source"]  as? String,
        let rev = args?["revenue"] as? Double,
        let cur = args?["currency"] as? String
      {
        Tapp.adjustTrackAdRevenue(source: src, revenue: rev, currency: cur)
      }
      result(nil)

    case "adjustTrackThirdPartySharing":
      if let en = args?["enabled"] as? Bool {
        Tapp.adjustTrackThirdPartySharing(isEnabled: en)
      }
      result(nil)

    case "getAdjustAttribution":
      Tapp.getAdjustAttribution { attr in
        var map: [String:Any] = [:]
        if let a = attr {
          map = [
            "trackerToken": a.trackerToken ?? "",
            "trackerName":  a.trackerName  ?? "",
            "network":      a.network      ?? "",
            "campaign":     a.campaign     ?? "",
            "adgroup":      a.adGroup      ?? "",
            "creative":     a.creative     ?? "",
            "clickLabel":   a.clickLabel   ?? "",
            "costType":     a.costType     ?? "",
            "costAmount":   a.costAmount?.doubleValue ?? 0.0,
            "costCurrency": a.costCurrency ?? ""
          ]
          if let dict = a.dictionary as? [String:Any] {
            map["fbInstallReferrer"] = dict["fbInstallReferrer"] as? String ?? ""
            map["costInUsd"]         = dict["costInUsd"]         as? Double ?? 0.0
            map["callbackParams"]    = dict["callbackParams"]    as? [String:Any] ?? [:]
            map["partnerParams"]     = dict["partnerParams"]     as? [String:Any] ?? [:]
          }
        }
        result(["attribution": map])
      }

    case "adjustVerifyAppStorePurchase":
      guard
        let tx  = args?["transactionId"] as? String,
        let pid = args?["productId"]     as? String
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing transactionId or productId", details: nil))
        return
      }
      Tapp.adjustVerifyAppStorePurchase(transactionId: tx, productId: pid) { resOpt in
        guard let res = resOpt else {
          result(FlutterError(code: "VERIFY_ERROR", message: "No result returned", details: nil))
          return
        }
        result([
          "verificationStatus": res.verificationStatus,
          "code":               Int(res.code),
          "message":            res.message
        ])
      }

    case "adjustTrackAppStoreSubscription":
      if
        let sub = args?["subscription"]      as? [String: Any],
        let price = sub["price"]             as? Double,
        let cur = sub["currency"]            as? String,
        let tx = sub["transactionId"]        as? String,
        let subscription = AdjustAppStoreSubscription(
          price: NSDecimalNumber(value: price),
          currency: cur,
          transactionId: tx
        )
      {
        Tapp.adjustTrackAppStoreSubscription(subscription)
        result(nil)
      } else {
        result(FlutterError(code: "BAD_ARGS", message: "Invalid subscription parameters", details: nil))
      }

    case "adjustConvert":
      guard
        let link = args?["universalLink"] as? String,
        let scheme = args?["scheme"] as? String,
        let url = URL(string: link)
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Invalid convert args", details: nil))
        return
      }
      let convertedURL = Tapp.adjustConvert(universalLink: url, with: scheme)
      result(convertedURL?.absoluteString)

    case "adjustRequestAppTrackingAuthorization":
      Tapp.adjustRequestAppTrackingAuthorization { status in result(status) }

    case "adjustAppTrackingAuthorizationStatus":
      result(Tapp.adjustAppTrackingAuthorizationStatus())

    case "adjustUpdateSkanConversionValue":
      guard
        let p   = args?["params"]    as? [String:Any],
        let val = p["value"]         as? Int,
        let coarse = p["coarseValue"] as? String
      else {
        result(FlutterError(code: "BAD_ARGS", message: "Missing SKAN conversion parameters", details: nil))
        return
      }
      let lockNumber: NSNumber? = (p["lockWindow"] as? Int).map { NSNumber(value: $0) }
      Tapp.adjustUpdateSkanConversionValue(val, coarseValue: coarse, lockWindow: lockNumber) { err in
        if let e = err {
          result(FlutterError(code: "SKAN_ERROR", message: e.localizedDescription, details: nil))
        } else {
          result(nil)
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

// MARK: - EventChannel

extension ComTappSoAdjustPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}

// MARK: - TappDelegate

extension ComTappSoAdjustPlugin: TappDelegate {
  // Called when a deferred deep link is opened
  public func didOpenApplication(with data: TappDeferredLinkData) {
    guard let sink = self.eventSink else { return }
    let map: [String:Any] = [
      "type": "onDeferredLinkReceived",
      "error": false,
      "message": "",
      "tappUrl": data.tappURL.absoluteString,
      "attrTappUrl": data.attributedTappURL.absoluteString,
      "influencer": data.influencer,
      "isFirstSession": data.isFirstSession,
      "data": data.data ?? [:]
    ]
    sink(map)
  }

  // Called when resolving the deferred URL fails
  public func didFailResolvingURL(url: URL, error: Error) {
    guard let sink = self.eventSink else { return }
    let map: [String:Any] = [
      "type": "onDidFailResolvingURL",
      "url": url.absoluteString,
      "error": error.localizedDescription
    ]
    sink(map)
  }
}
