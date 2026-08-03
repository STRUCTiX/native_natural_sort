import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNativeNaturalSort platform = MethodChannelNativeNaturalSort();
  const MethodChannel channel = MethodChannel('native_natural_sort');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
