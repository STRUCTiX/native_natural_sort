import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

part 'natural_sort_android_tests.dart';
part 'natural_sort_apple_tests.dart';
part 'natural_sort_basic_tests.dart';
part 'natural_sort_edge_cases_tests.dart';
part 'natural_sort_linux_tests.dart';
part 'natural_sort_locale_tests.dart';
part 'natural_sort_windows_ffi_tests.dart';
part 'natural_sort_windows_pigeon_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Cross-platform tests — always run.
  registerBasicSortTests();
  registerEdgeCaseTests();
  registerLocaleTests();

  // Platform-specific tests — only register on matching platform.
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      registerAndroidTests();
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      registerAppleTests();
    case TargetPlatform.linux:
      registerLinuxTests();
    case TargetPlatform.windows:
      registerWindowsPigeonTests();
      registerWindowsFfiTests();
    case TargetPlatform.fuchsia:
      break;
  }
}
