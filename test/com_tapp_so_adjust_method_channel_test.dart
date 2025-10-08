import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelComTappSoAdjust platform = MethodChannelComTappSoAdjust();
  const MethodChannel channel = MethodChannel('com_tapp_so_adjust');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
