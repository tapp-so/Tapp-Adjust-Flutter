import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'com_tapp_so_adjust_platform_interface.dart';

/// An implementation of [ComTappSoAdjustPlatform] that uses method channels.
class MethodChannelComTappSoAdjust extends ComTappSoAdjustPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com_tapp_so_adjust');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
