
import 'native_natural_sort_platform_interface.dart';

class NativeNaturalSort {
  Future<String?> getPlatformVersion() {
    return NativeNaturalSortPlatform.instance.getPlatformVersion();
  }
}
