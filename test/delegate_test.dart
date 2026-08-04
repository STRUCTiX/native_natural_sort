import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('PlatformDelegate', () {
    test('is an abstract interface with init and sort', () {
      // Verify the interface shape — no concrete functionality to test.
      final delegate = _StubDelegate();
      expect(delegate, isA<PlatformDelegate>());
    });
  });
}

class _StubDelegate extends PlatformDelegate {
  @override
  Future<void> init(SortOptions options) async {}

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async => items;

  @override
  Future<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) async => items;
}
