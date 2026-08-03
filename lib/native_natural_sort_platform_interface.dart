import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_natural_sort_method_channel.dart';

abstract class NativeNaturalSortPlatform extends PlatformInterface {
  /// Constructs a NativeNaturalSortPlatform.
  NativeNaturalSortPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeNaturalSortPlatform _instance = MethodChannelNativeNaturalSort();

  /// The default instance of [NativeNaturalSortPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeNaturalSort].
  static NativeNaturalSortPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeNaturalSortPlatform] when
  /// they register themselves.
  static set instance(NativeNaturalSortPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
