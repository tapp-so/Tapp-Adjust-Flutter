// lib/src/models.dart

// ignore_for_file: constant_identifier_names

/// Fired when a deferred deep link arrives
class DeferredDeepLinkData {
  final bool? error;
  final String? message;
  final String? tappUrl;
  final String? attrTappUrl;
  final String? influencer;
  final bool? isFirstSession;
  final Map<String, String>? data;

  DeferredDeepLinkData({
    this.error,
    this.message,
    this.tappUrl,
    this.attrTappUrl,
    this.influencer,
    this.isFirstSession,
    this.data,
  });

  factory DeferredDeepLinkData.fromMap(Map<String, dynamic>? m) {
    if (m == null) return DeferredDeepLinkData();
    return DeferredDeepLinkData(
      error: m['error'] as bool?,
      message: m['message'] as String?,
      tappUrl: m['tappUrl'] as String?,
      attrTappUrl: m['attrTappUrl'] as String?,
      influencer: m['influencer'] as String?,
      isFirstSession: m['isFirstSession'] as bool?,
      data: (m['data'] as Map?)?.cast<String, String>(),
    );
  }

  @override
  String toString() {
    return 'DeferredDeepLinkData('
        'error: $error, '
        'message: $message, '
        'tappUrl: $tappUrl, '
        'attrTappUrl: $attrTappUrl, '
        'influencer: $influencer, '
        'isFirstSession: $isFirstSession, '
        'data: $data'
        ')';
  }
}

/// Fired when resolving the deferred link fails
class FailResolveData {
  final String? url;
  final String? error;

  FailResolveData({
    this.url,
    this.error,
  });

  factory FailResolveData.fromMap(Map<String, dynamic>? m) {
    if (m == null) return FailResolveData();
    return FailResolveData(
      url: m['url'] as String?,
      error: m['error'] as String?,
    );
  }

  @override
  String toString() => 'FailResolveData(url: $url, error: $error)';
}

/// Result of fetchLinkData / fetchOriginLinkData
class LinkData {
  final bool? error;
  final String? message;
  final String? tappUrl;
  final String? attrTappUrl;
  final String? influencer;
  final bool? isFirstSession;
  final Map<String, String>? data;

  LinkData({
    this.error,
    this.message,
    this.tappUrl,
    this.attrTappUrl,
    this.influencer,
    this.isFirstSession,
    this.data,
  });

  factory LinkData.fromMap(Map<String, dynamic>? m) {
    if (m == null) return LinkData();
    return LinkData(
      error: m['error'] as bool?,
      message: m['message'] as String?,
      tappUrl: m['tappUrl'] as String?,
      attrTappUrl: m['attrTappUrl'] as String?,
      influencer: m['influencer'] as String?,
      isFirstSession: m['isFirstSession'] as bool?,
      data: (m['data'] as Map?)?.cast<String, String>(),
    );
  }

  @override
  String toString() {
    return 'LinkData('
        'error: $error, '
        'message: $message, '
        'tappUrl: $tappUrl, '
        'attrTappUrl: $attrTappUrl, '
        'influencer: $influencer, '
        'isFirstSession: $isFirstSession, '
        'data: $data'
        ')';
  }
}

/// Result of getConfig
class Config {
  final bool? error;
  final String? message;
  final InnerConfig? config;

  Config({
    this.error,
    this.message,
    this.config,
  });

  factory Config.fromMap(Map<String, dynamic>? m) {
    if (m == null) return Config();
    // Cast the nested map to Map<String, dynamic>, if present
    final configMap = (m['config'] as Map?)?.cast<String, dynamic>();
    return Config(
      error: m['error'] as bool?,
      message: m['message'] as String?,
      config: configMap != null ? InnerConfig.fromMap(configMap) : null,
    );
  }

  @override
  String toString() {
    return 'Config('
        'error: $error, '
        'message: $message, '
        'config: $config'
        ')';
  }
}

class InnerConfig {
  final String? authToken;
  final String? env;
  final String? tappToken;
  final String? affiliate;
  final String? bundleID;
  final String? appToken;
  final String? deepLinkUrl;
  final String? linkToken;

  InnerConfig({
    this.authToken,
    this.env,
    this.tappToken,
    this.affiliate,
    this.bundleID,
    this.appToken,
    this.deepLinkUrl,
    this.linkToken,
  });

  factory InnerConfig.fromMap(Map<String, dynamic>? m) {
    if (m == null) return InnerConfig();
    return InnerConfig(
      authToken: m['authToken'] as String?,
      env: m['env'] as String?,
      tappToken: m['tappToken'] as String?,
      affiliate: m['affiliate'] as String?,
      bundleID: m['bundleID'] as String?,
      appToken: m['appToken'] as String?,
      deepLinkUrl: m['deepLinkUrl'] as String?,
      linkToken: m['linkToken'] as String?,
    );
  }

  @override
  String toString() {
    return 'InnerConfig('
        'authToken: $authToken, '
        'env: $env, '
        'tappToken: $tappToken, '
        'affiliate: $affiliate, '
        'bundleID: $bundleID, '
        'appToken: $appToken, '
        'deepLinkUrl: $deepLinkUrl, '
        'linkToken: $linkToken'
        ')';
  }
}

/// ——— Now the new types to match your React-Native API ———

/// Initialization options
class InitConfig {
  final String? authToken;
  final EnvironmentType? env;
  final String? tappToken;
  final AffiliateType? affiliate;

  InitConfig({
    this.authToken,
    this.env,
    this.tappToken,
    this.affiliate,
  });

  @override
  String toString() {
    return 'InitConfig('
        'authToken: $authToken, '
        'env: $env, '
        'tappToken: $tappToken, '
        'affiliate: $affiliate'
        ')';
  }
}

/// Sandbox vs Production environments
enum EnvironmentType { PRODUCTION, SANDBOX }

/// Affiliate partners
enum AffiliateType { ADJUST, APPFLYER, TAPP }

/// Built-in tapp event actions (CUSTOM == 0)
/// Built-in tapp event actions
enum EventAction {
  custom,
  tapp_add_payment_info,
  tapp_add_to_cart,
  tapp_add_to_wishlist,
  tapp_complete_registration,
  tapp_contact,
  tapp_customize_product,
  tapp_donate,
  tapp_find_location,
  tapp_initiate_checkout,
  tapp_generate_lead,
  tapp_purchase,
  tapp_schedule,
  tapp_search,
  tapp_start_trial,
  tapp_submit_application,
  tapp_subscribe,
  tapp_view_content,
  tapp_click_button,
  tapp_download_file,
  tapp_join_group,
  tapp_achieve_level,
  tapp_create_group,
  tapp_create_role,
  tapp_link_click,
  tapp_link_impression,
  tapp_apply_for_loan,
  tapp_loan_approval,
  tapp_loan_disbursal,
  tapp_login,
  tapp_rate,
  tapp_spend_credits,
  tapp_unlock_achievement,
  tapp_add_shipping_info,
  tapp_earn_virtual_currency,
  tapp_start_level,
  tapp_complete_level,
  tapp_post_score,
  tapp_select_content,
  tapp_begin_tutorial,
  tapp_complete_tutorial,
}

/// How to call handleTappEvent from Dart
class TappEventType {
  final EventAction? eventAction;
  final String? customValue;

  TappEventType({
    this.eventAction,
    this.customValue,
  });

  @override
  String toString() {
    return 'TappEventType('
        'eventAction: $eventAction, '
        'customValue: $customValue'
        ')';
  }
}

/// Adjust ad revenue tracking parameters
class AdjustTrackAdRevenueType {
  final String? source;
  final double? revenue;
  final String? currency;

  AdjustTrackAdRevenueType({
    this.source,
    this.revenue,
    this.currency,
  });

  @override
  String toString() {
    return 'AdjustTrackAdRevenueType('
        'source: $source, '
        'revenue: $revenue, '
        'currency: $currency'
        ')';
  }
}

/// Result of a purchase-verification call
class VerifyResult {
  final String? verificationStatus;
  final int? code;
  final String? message;

  VerifyResult({
    this.verificationStatus,
    this.code,
    this.message,
  });

  @override
  String toString() {
    return 'VerifyResult('
        'verificationStatus: $verificationStatus, '
        'code: $code, '
        'message: $message'
        ')';
  }
}

/// Attribution data returned by Adjust
class AdjustAttributionType {
  final String? adid;
  final String? trackerToken;
  final String? trackerName;
  final String? network;
  final String? campaign;
  final String? adgroup;
  final String? creative;
  final String? clickLabel;
  final String? costType;
  final double? costAmount;
  final String? costCurrency;
  final String? fbInstallReferrer;
  final double? costInUsd;
  final Map<String, String>? callbackParams;
  final Map<String, String>? partnerParams;

  AdjustAttributionType({
    this.adid,
    this.trackerToken,
    this.trackerName,
    this.network,
    this.campaign,
    this.adgroup,
    this.creative,
    this.clickLabel,
    this.costType,
    this.costAmount,
    this.costCurrency,
    this.fbInstallReferrer,
    this.costInUsd,
    this.callbackParams,
    this.partnerParams,
  });

  @override
  String toString() {
    return 'AdjustAttributionType('
        'adid: $adid, '
        'trackerToken: $trackerToken, '
        'trackerName: $trackerName, '
        'network: $network, '
        'campaign: $campaign, '
        'adgroup: $adgroup, '
        'creative: $creative, '
        'clickLabel: $clickLabel, '
        'costType: $costType, '
        'costAmount: $costAmount, '
        'costCurrency: $costCurrency, '
        'fbInstallReferrer: $fbInstallReferrer, '
        'costInUsd: $costInUsd, '
        'callbackParams: $callbackParams, '
        'partnerParams: $partnerParams'
        ')';
  }
}

/// iOS App-Store subscription
class AppStoreSubscription {
  final double? price;
  final String? currency;
  final String? transactionId;
  final int? transactionDate;
  final String? salesRegion;
  final Map<String, String>? callbackParameters;
  final Map<String, String>? partnerParameters;

  AppStoreSubscription({
    this.price,
    this.currency,
    this.transactionId,
    this.transactionDate,
    this.salesRegion,
    this.callbackParameters,
    this.partnerParameters,
  });

  @override
  String toString() {
    return 'AppStoreSubscription('
        'price: $price, '
        'currency: $currency, '
        'transactionId: $transactionId, '
        'transactionDate: $transactionDate, '
        'salesRegion: $salesRegion, '
        'callbackParameters: $callbackParameters, '
        'partnerParameters: $partnerParameters'
        ')';
  }
}

/// Android Play-Store subscription
class PlayStoreSubscription {
  final double? price;
  final String? currency;
  final String? sku;
  final String? orderId;
  final String? signature;
  final String? purchaseToken;
  final int? purchaseTime;

  PlayStoreSubscription({
    this.price,
    this.currency,
    this.sku,
    this.orderId,
    this.signature,
    this.purchaseToken,
    this.purchaseTime,
  });

  @override
  String toString() {
    return 'PlayStoreSubscription('
        'price: $price, '
        'currency: $currency, '
        'sku: $sku, '
        'orderId: $orderId, '
        'signature: $signature, '
        'purchaseToken: $purchaseToken, '
        'purchaseTime: $purchaseTime'
        ')';
  }
}

/// SKAdNetwork conversion-value update
class UpdateSkanConversionValueType {
  final int? value;
  final String? coarseValue;
  final int? lockWindow;

  UpdateSkanConversionValueType({
    this.value,
    this.coarseValue,
    this.lockWindow,
  });

  @override
  String toString() {
    return 'UpdateSkanConversionValueType('
        'value: $value, '
        'coarseValue: $coarseValue, '
        'lockWindow: $lockWindow'
        ')';
  }
}

/// iOS-only verify+track-playstore purchase call
class VerifyPlayStorePurchaseType {
  final String? transactionId;
  final String? productId;

  VerifyPlayStorePurchaseType({
    this.transactionId,
    this.productId,
  });

  @override
  String toString() {
    return 'VerifyPlayStorePurchaseType('
        'transactionId: $transactionId, '
        'productId: $productId'
        ')';
  }
}

/// Completion callback for the above
typedef VerifyPlayStorePurchaseCompletionType = void Function(
    VerifyResult? result);

/// If someone wants to implement a deferred-link delegate in Dart
abstract class DeferredLinkDelegate {
  void didReceiveDeferredLink(DeferredDeepLinkData? linkDataResponse);
  void testListener(String? test);
}
