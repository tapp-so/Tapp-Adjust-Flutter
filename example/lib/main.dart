import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _sdk = ComTappSoAdjust();

  StreamSubscription<DeferredDeepLinkData>? _deferredSub;
  StreamSubscription<FailResolveData>? _failSub;
  StreamSubscription<String?>? _testListener;

  // —— Core SDK state
  String _version = '…';
  String _should = '…';
  String _url = '…';
  String _evt = '…';
  String _tappEvt = '…';
  String _link = '…';
  String _orig = '…';
  String _cfg = '…';

  String _testMsg = '…';

  // —— Deferred‐link events
  String _deferred = '…';
  String _fail = '…';

  // —— Adjust integration state
  String _adjustEnableResult = '…';
  String _adjustDisableResult = '…';
  String _adjustIsEnabledResult = '…';
  String _adjustGdprResult = '…';
  String _referrerResult = '…';
  String _pushTokenResult = '…';
  String _trackAdRevenueResult = '…';
  String _thirdPartyResult = '…';
  String _measurementResult = '…';
  String _addCallbackResult = '…';
  String _addPartnerResult = '…';
  String _removeCallbackResult = '…';
  String _removePartnerResult = '…';
  String _removeAllCallbacks = '…';
  String _removeAllPartners = '…';
  String _adidResult = '…';
  String _idfaResult = '…';
  String _gAdIdResult = '…';
  String _amzAdIdResult = '…';
  String _sdkVersionResult = '…';
  String _installReferrerResult = '…';
  String _onResumeResult = '…';
  String _onPauseResult = '…';
  String _verifyAppResult = '…';
  String _verifyPlayResult = '…';
  String _trackPlayResult = '…';
  String _trackAppResult = '…';
  String _convertResult = '…';
  String _reqAuthResult = '…';
  String _authStatusResult = '…';
  String _skanResult = '…';

  @override
  void initState() {
    super.initState();
    _initializeSdk();

    _deferredSub = _sdk.onDeferredDeepLink.listen((data) {
      if (!mounted) return;
      setState(() {
        _deferred = '''
        URL: ${data.tappUrl}
        influencer: ${data.influencer}
        firstSession: ${data.isFirstSession}
        extraData: ${data.data}
        ''';
      });
    });
    _failSub = _sdk.onFailResolvingUrl.listen((err) {
      if (!mounted) return;
      setState(() {
        _fail = 'url=${err.url}\nerror=${err.error}';
      });
    });
    // Test listener
    _testListener = _sdk.onTestListener.listen((msg) {
      if (!mounted) return;
      setState(() => _testMsg = msg ?? 'null');
    });
  }

  @override
  void dispose() {
    _deferredSub?.cancel();
    _failSub?.cancel();
    _testListener?.cancel();
    super.dispose();
  }

  Future<void> _showUnsupported(String method) async {
    debugPrint('[${Platform.operatingSystem}] "$method" is not supported.');
  }

  Future<void> _initializeSdk() async {
    try {
      await _sdk.start(
        authToken: 'authToken',
        env: EnvironmentType.SANDBOX,
        tappToken: 'tappToken',
      );
    } on PlatformException {
      // ignore
    }
    await _getVersion();
    await _checkShouldProcess();
  }

  //–– Core handlers ––

  Future<void> _getVersion() async {
    final v = await _sdk.getPlatformVersion();
    if (!mounted) return;
    setState(() => _version = v ?? 'Unknown');
  }

  Future<void> _checkShouldProcess() async {
    final ok = await _sdk.shouldProcess('https://example.com');
    if (!mounted) return;
    setState(() => _should = ok.toString());
  }

  Future<void> _generateUrl() async {
    final u = await _sdk.generateUrl(
      influencer: 'influencer_flutter',
      adGroup: 'group',
      creative: 'creative',
      data: {'foo': 'bar'},
    );
    if (!mounted) return;
    setState(() => _url = u ?? 'error');
  }

  Future<void> _handleEvent() async {
    await _sdk.handleEvent('myEventToken');
    if (!mounted) return;
    setState(() => _evt = 'OK');
  }

  Future<void> _handleTappEvent() async {
    await _sdk.handleTappEvent(
      eventAction: EventAction.tapp_purchase,
    );
    if (!mounted) return;
    setState(() => _tappEvt = 'OK');
  }

  Future<void> _fetchLinkData() async {
    final link = await _sdk.fetchLinkData('https://example.com');
    if (!mounted) return;
    setState(() => _link = link?.toString() ?? 'null');
  }

  Future<void> _fetchOriginLinkData() async {
    final link = await _sdk.fetchOriginLinkData();
    if (!mounted) return;
    setState(() => _orig = link?.toString() ?? 'null');
  }

  Future<void> _getConfig() async {
    final cfg = await _sdk.getConfig();
    if (!mounted) return;
    setState(() => _cfg = cfg?.toString() ?? 'null');
  }

  //–– Adjust handlers ––

  Future<void> _onAdjustEnable() async {
    if (Platform.isIOS) {
      await _showUnsupported('adjustEnable');
      return;
    }
    await _sdk.adjustEnable();
    setState(() => _adjustEnableResult = 'OK');
  }

  Future<void> _onAdjustDisable() async {
    if (Platform.isIOS) {
      await _showUnsupported('adjustDisable');
      return;
    }
    await _sdk.adjustDisable();
    setState(() => _adjustDisableResult = 'OK');
  }

  Future<void> _onAdjustIsEnabled() async {
    if (Platform.isIOS) {
      await _showUnsupported('adjustIsEnabled');
      return;
    }
    final b = await _sdk.adjustIsEnabled();
    setState(() => _adjustIsEnabledResult = b.toString());
  }

  Future<void> _onAdjustGdprForgetMe() async {
    if (Platform.isIOS) {
      await _showUnsupported('adjustGdprForgetMe');
      return;
    }
    await _sdk.adjustGdprForgetMe();
    setState(() => _adjustGdprResult = 'OK');
  }

  Future<void> _onAdjustSetReferrer() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustSetReferrer');
      return;
    }
    await _sdk.adjustSetReferrer('referrer');
    setState(() => _referrerResult = 'OK');
  }

  Future<void> _onAdjustSetPushToken() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustSetPushToken');
      return;
    }
    await _sdk.adjustSetPushToken('pushToken');
    setState(() => _pushTokenResult = 'OK');
  }

  Future<void> _onAdjustTrackAdRevenue() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustTrackAdRevenue');
      return;
    }
    await _sdk.adjustTrackAdRevenue(
      AdjustTrackAdRevenueType(
        source: 'source',
        revenue: 9.99,
        currency: 'USD',
      ),
    );
    setState(() => _trackAdRevenueResult = 'OK');
  }

  Future<void> _onAdjustTrackThirdPartySharing() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustTrackThirdPartySharing');
      return;
    }
    await _sdk.adjustTrackThirdPartySharing(true);
    setState(() => _thirdPartyResult = 'OK');
  }

  Future<void> _onAdjustTrackMeasurementConsent() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustTrackMeasurementConsent');
      return;
    }
    await _sdk.adjustTrackMeasurementConsent(false);
    setState(() => _measurementResult = 'OK');
  }

  Future<void> _onAdjustAddGlobalCallbackParameter() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustAddGlobalCallbackParameter');
      return;
    }
    await _sdk.adjustAddGlobalCallbackParameter('key', 'value');
    setState(() => _addCallbackResult = 'OK');
  }

  Future<void> _onAdjustAddGlobalPartnerParameter() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustAddGlobalPartnerParameter');
      return;
    }
    await _sdk.adjustAddGlobalPartnerParameter('key', 'value');
    setState(() => _addPartnerResult = 'OK');
  }

  Future<void> _onAdjustRemoveGlobalCallbackParameter() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustRemoveGlobalCallbackParameter');
      return;
    }
    await _sdk.adjustRemoveGlobalCallbackParameter('key');
    setState(() => _removeCallbackResult = 'OK');
  }

  Future<void> _onAdjustRemoveGlobalPartnerParameter() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustRemoveGlobalPartnerParameter');
      return;
    }
    await _sdk.adjustRemoveGlobalPartnerParameter('key');
    setState(() => _removePartnerResult = 'OK');
  }

  Future<void> _onAdjustRemoveGlobalCallbackParameters() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustRemoveGlobalCallbackParameters');
      return;
    }
    await _sdk.adjustRemoveGlobalCallbackParameters();
    setState(() => _removeAllCallbacks = 'OK');
  }

  Future<void> _onAdjustRemoveGlobalPartnerParameters() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustRemoveGlobalPartnerParameters');
      return;
    }
    await _sdk.adjustRemoveGlobalPartnerParameters();
    setState(() => _removeAllPartners = 'OK');
  }

  Future<void> _onAdjustGetAdid() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustGetAdid');
      return;
    }
    final s = await _sdk.adjustGetAdid();
    setState(() => _adidResult = s ?? 'null');
  }

  Future<void> _onAdjustGetIdfa() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustGetIdfa');
      return;
    }
    final s = await _sdk.adjustGetIdfa();
    setState(() => _idfaResult = s ?? 'null');
  }

  Future<void> _onAdjustGetGoogleAdId() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustGetGoogleAdId');
      return;
    }
    final s = await _sdk.adjustGetGoogleAdId();
    setState(() => _gAdIdResult = s ?? 'null');
  }

  Future<void> _onAdjustGetAmazonAdId() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustGetAmazonAdId');
      return;
    }
    final s = await _sdk.adjustGetAmazonAdId();
    setState(() => _amzAdIdResult = s ?? 'null');
  }

  Future<void> _onAdjustGetSdkVersion() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustGetSdkVersion');
      return;
    }
    final s = await _sdk.adjustGetSdkVersion();
    setState(() => _sdkVersionResult = s ?? 'null');
  }

  Future<void> _onAdjustGetGooglePlayInstallReferrer() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustGetGooglePlayInstallReferrer');
      return;
    }
    final s = await _sdk.adjustGetGooglePlayInstallReferrer();
    setState(() => _installReferrerResult = s ?? 'null');
  }

  Future<void> _onAdjustOnResume() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustOnResume');
      return;
    }
    await _sdk.adjustOnResume();
    setState(() => _onResumeResult = 'OK');
  }

  Future<void> _onAdjustOnPause() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustOnPause');
      return;
    }
    await _sdk.adjustOnPause();
    setState(() => _onPauseResult = 'OK');
  }

  Future<void> _onAdjustVerifyAppStorePurchase() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustVerifyAppStorePurchase');
      return;
    }
    final res = await _sdk.adjustVerifyAppStorePurchase(
      transactionId: 'tx',
      productId: 'pid',
    );
    setState(() => _verifyAppResult = res.toString());
  }

  Future<void> _onAdjustVerifyPlayStorePurchase() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustVerifyPlayStorePurchase');
      return;
    }
    final res = await _sdk.adjustVerifyAndTrackPlayStorePurchase(
      eventToken: 'eventToken',
    );
    setState(() => _verifyPlayResult = res.toString());
  }

  Future<void> _onAdjustTrackPlayStoreSubscription() async {
    if (!Platform.isAndroid) {
      await _showUnsupported('adjustTrackPlayStoreSubscription');
      return;
    }
    await _sdk.adjustTrackPlayStoreSubscription(
      PlayStoreSubscription(
        price: 1.23,
        currency: 'USD',
        sku: 'sku',
        orderId: 'o',
        signature: 'sig',
        purchaseToken: 'token',
        purchaseTime: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    setState(() => _trackPlayResult = 'OK');
  }

  Future<void> _onAdjustTrackAppStoreSubscription() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustTrackAppStoreSubscription');
      return;
    }
    await _sdk.adjustTrackAppStoreSubscription(
      AppStoreSubscription(
        price: 1.23,
        currency: 'USD',
        transactionId: 'txId',
      ),
    );
    setState(() => _trackAppResult = 'OK');
  }

  Future<void> _onAdjustConvert() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustConvert');
      return;
    }
    final s = await _sdk.adjustConvert('https://univ.link', 'myScheme');
    setState(() => _convertResult = s ?? 'null');
  }

  Future<void> _onAdjustRequestAppTrackingAuthorization() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustRequestAppTrackingAuthorization');
      return;
    }
    final i = await _sdk.adjustRequestAppTrackingAuthorization();
    setState(() => _reqAuthResult = i.toString());
  }

  Future<void> _onAdjustAppTrackingAuthorizationStatus() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustAppTrackingAuthorizationStatus');
      return;
    }
    final i = await _sdk.adjustAppTrackingAuthorizationStatus();
    setState(() => _authStatusResult = i.toString());
  }

  Future<void> _onAdjustUpdateSkanConversionValue() async {
    if (!Platform.isIOS) {
      await _showUnsupported('adjustUpdateSkanConversionValue');
      return;
    }
    await _sdk.adjustUpdateSkanConversionValue(
      UpdateSkanConversionValueType(
        value: 1,
        coarseValue: 'medium',
        lockWindow: 0,
      ),
    );
    setState(() => _skanResult = 'OK');
  }

  Future<void> _simulateTestEvent() async {
    await _sdk.simulateTestEvent();
  }

  Widget _buildButton(String label, VoidCallback onTap, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: onTap, child: Text(label)),
        const SizedBox(height: 6),
        Text(value),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tapp SDK Example')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Core
            _buildButton('Get Platform Version', _getVersion, _version),
            _buildButton('Should Process URL', _checkShouldProcess, _should),
            _buildButton('Generate URL', _generateUrl, _url),
            _buildButton('Handle Event', _handleEvent, _evt),
            _buildButton('Handle Tapp Event', _handleTappEvent, _tappEvt),
            _buildButton('Fetch Link Data', _fetchLinkData, _link),
            _buildButton('Fetch Origin Link Data', _fetchOriginLinkData, _orig),
            _buildButton('Get Config', _getConfig, _cfg),

            // Deferred
            const SizedBox(height: 16),
            const Text('Deferred Link Events',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Received:\n$_deferred'),
            Text('Fail Resolve:\n$_fail'),
            const Divider(),
            // Test Simulation
            const SizedBox(height: 16),
            _buildButton('Simulate Test Event', _simulateTestEvent, _testMsg),
            // Adjust
            _buildButton('adjustEnable', _onAdjustEnable, _adjustEnableResult),
            _buildButton(
                'adjustDisable', _onAdjustDisable, _adjustDisableResult),
            _buildButton(
                'adjustIsEnabled', _onAdjustIsEnabled, _adjustIsEnabledResult),
            _buildButton(
                'adjustGdprForgetMe', _onAdjustGdprForgetMe, _adjustGdprResult),
            _buildButton(
                'adjustSetReferrer', _onAdjustSetReferrer, _referrerResult),
            _buildButton(
                'adjustSetPushToken', _onAdjustSetPushToken, _pushTokenResult),
            _buildButton('adjustTrackAdRevenue', _onAdjustTrackAdRevenue,
                _trackAdRevenueResult),
            _buildButton('adjustTrackThirdPartySharing',
                _onAdjustTrackThirdPartySharing, _thirdPartyResult),
            _buildButton('adjustTrackMeasurementConsent',
                _onAdjustTrackMeasurementConsent, _measurementResult),
            _buildButton('adjustAddGlobalCallbackParameter',
                _onAdjustAddGlobalCallbackParameter, _addCallbackResult),
            _buildButton('adjustAddGlobalPartnerParameter',
                _onAdjustAddGlobalPartnerParameter, _addPartnerResult),
            _buildButton('adjustRemoveGlobalCallbackParameter',
                _onAdjustRemoveGlobalCallbackParameter, _removeCallbackResult),
            _buildButton('adjustRemoveGlobalPartnerParameter',
                _onAdjustRemoveGlobalPartnerParameter, _removePartnerResult),
            _buildButton('adjustRemoveGlobalCallbackParameters',
                _onAdjustRemoveGlobalCallbackParameters, _removeAllCallbacks),
            _buildButton('adjustRemoveGlobalPartnerParameters',
                _onAdjustRemoveGlobalPartnerParameters, _removeAllPartners),
            _buildButton('adjustGetAdid', _onAdjustGetAdid, _adidResult),
            _buildButton('adjustGetIdfa', _onAdjustGetIdfa, _idfaResult),
            _buildButton(
                'adjustGetGoogleAdId', _onAdjustGetGoogleAdId, _gAdIdResult),
            _buildButton(
                'adjustGetAmazonAdId', _onAdjustGetAmazonAdId, _amzAdIdResult),
            _buildButton('adjustGetSdkVersion', _onAdjustGetSdkVersion,
                _sdkVersionResult),
            _buildButton('adjustGetGooglePlayInstallReferrer',
                _onAdjustGetGooglePlayInstallReferrer, _installReferrerResult),
            _buildButton('adjustOnResume', _onAdjustOnResume, _onResumeResult),
            _buildButton('adjustOnPause', _onAdjustOnPause, _onPauseResult),
            _buildButton('adjustVerifyAppStorePurchase',
                _onAdjustVerifyAppStorePurchase, _verifyAppResult),
            _buildButton('adjustVerifyPlayStorePurchase',
                _onAdjustVerifyPlayStorePurchase, _verifyPlayResult),
            _buildButton('adjustTrackPlayStoreSubscription',
                _onAdjustTrackPlayStoreSubscription, _trackPlayResult),
            _buildButton('adjustTrackAppStoreSubscription',
                _onAdjustTrackAppStoreSubscription, _trackAppResult),
            _buildButton('adjustConvert', _onAdjustConvert, _convertResult),
            _buildButton('adjustRequestAppTrackingAuthorization',
                _onAdjustRequestAppTrackingAuthorization, _reqAuthResult),
            _buildButton('adjustAppTrackingAuthorizationStatus',
                _onAdjustAppTrackingAuthorizationStatus, _authStatusResult),
            _buildButton('adjustUpdateSkanConversionValue',
                _onAdjustUpdateSkanConversionValue, _skanResult),
          ]),
        ),
      ),
    );
  }
}
