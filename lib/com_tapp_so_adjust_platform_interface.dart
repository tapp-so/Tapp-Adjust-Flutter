// lib/src/com_tapp_so_adjust_platform_interface.dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'com_tapp_so_adjust_method_channel.dart';

/// Platform interface for com_tapp_so_adjust.
///
/// Keep this in sync with the MethodChannel implementation so that
/// alternative platform implementations (e.g., FFI, web, mock) can be used.
abstract class ComTappSoAdjustPlatform extends PlatformInterface {
  ComTappSoAdjustPlatform() : super(token: _token);
  static final Object _token = Object();

  static ComTappSoAdjustPlatform _instance = MethodChannelComTappSoAdjust();

  /// Default instance used by the public API.
  static ComTappSoAdjustPlatform get instance => _instance;

  /// Set by platform-specific implementations.
  static set instance(ComTappSoAdjustPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ---- Core ----

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Initialize native SDK with a config map
  /// {
  ///   "authToken": String,
  ///   "environment": "prod" | "staging",
  ///   "tappToken": String,
  ///   "affiliate": String (e.g., "adjust")
  /// }
  Future<bool?> initialize(Map<String, dynamic> config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Decide if a deep link should be handled by the SDK
  Future<bool?> shouldProcess(Map<String, dynamic> args) {
    throw UnimplementedError('shouldProcess() has not been implemented.');
  }

  /// Generate a tapp URL from arguments
  Future<String?> generateUrl(Map<String, dynamic> args) {
    throw UnimplementedError('generateUrl() has not been implemented.');
  }

  /// Track a simple event (e.g., Adjust event token)
  Future<bool?> handleEvent(Map<String, dynamic> args) {
    throw UnimplementedError('handleEvent() has not been implemented.');
  }

  /// Track a tapp-domain event (purchase, referral, etc.)
  Future<bool?> handleTappEvent(Map<String, dynamic> args) {
    throw UnimplementedError('handleTappEvent() has not been implemented.');
  }

  /// Fetch deferred link data
  Future<Map<String, dynamic>?> fetchLinkData() {
    throw UnimplementedError('fetchLinkData() has not been implemented.');
  }

  /// Fetch original install link data
  Future<Map<String, dynamic>?> fetchOriginLinkData() {
    throw UnimplementedError('fetchOriginLinkData() has not been implemented.');
  }

  /// Return current SDK config (platform-dependent)
  Future<Map<String, dynamic>?> getConfig() {
    throw UnimplementedError('getConfig() has not been implemented.');
  }
}
