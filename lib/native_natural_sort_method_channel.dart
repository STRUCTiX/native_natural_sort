import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_natural_sort_platform_interface.dart';

/// An implementation of [NativeNaturalSortPlatform] that uses method channels.
class MethodChannelNativeNaturalSort extends NativeNaturalSortPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_natural_sort');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
