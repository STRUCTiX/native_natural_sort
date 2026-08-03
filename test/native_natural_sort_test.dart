import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/native_natural_sort_platform_interface.dart';
import 'package:native_natural_sort/native_natural_sort_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeNaturalSortPlatform
    with MockPlatformInterfaceMixin
    implements NativeNaturalSortPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeNaturalSortPlatform initialPlatform = NativeNaturalSortPlatform.instance;

  test('$MethodChannelNativeNaturalSort is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeNaturalSort>());
  });

  test('getPlatformVersion', () async {
    NativeNaturalSort nativeNaturalSortPlugin = NativeNaturalSort();
    MockNativeNaturalSortPlatform fakePlatform = MockNativeNaturalSortPlatform();
    NativeNaturalSortPlatform.instance = fakePlatform;

    expect(await nativeNaturalSortPlugin.getPlatformVersion(), '42');
  });
}
