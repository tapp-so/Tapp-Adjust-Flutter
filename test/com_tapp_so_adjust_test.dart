import 'package:flutter_test/flutter_test.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust_platform_interface.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockComTappSoAdjustPlatform
    with MockPlatformInterfaceMixin
    implements ComTappSoAdjustPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>?> fetchLinkData() {
    // TODO: implement fetchLinkData
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchOriginLinkData() {
    // TODO: implement fetchOriginLinkData
    throw UnimplementedError();
  }

  @override
  Future<String?> generateUrl(Map<String, dynamic> args) {
    // TODO: implement generateUrl
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getConfig() {
    // TODO: implement getConfig
    throw UnimplementedError();
  }

  @override
  Future<bool?> handleEvent(Map<String, dynamic> args) {
    // TODO: implement handleEvent
    throw UnimplementedError();
  }

  @override
  Future<bool?> handleTappEvent(Map<String, dynamic> args) {
    // TODO: implement handleTappEvent
    throw UnimplementedError();
  }

  @override
  Future<bool?> initialize(Map<String, dynamic> config) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<bool?> shouldProcess(Map<String, dynamic> args) {
    // TODO: implement shouldProcess
    throw UnimplementedError();
  }
}

void main() {
  final ComTappSoAdjustPlatform initialPlatform =
      ComTappSoAdjustPlatform.instance;

  test('$MethodChannelComTappSoAdjust is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelComTappSoAdjust>());
  });

  test('getPlatformVersion', () async {
    ComTappSoAdjust comTappSoAdjustPlugin = ComTappSoAdjust();
    MockComTappSoAdjustPlatform fakePlatform = MockComTappSoAdjustPlatform();
    ComTappSoAdjustPlatform.instance = fakePlatform;

    expect(await comTappSoAdjustPlugin.getPlatformVersion(), '42');
  });
}
