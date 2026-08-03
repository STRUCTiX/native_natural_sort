import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('MacOSDelegate', () {
    test('init stores direction and sort from options', () async {
      final mockSort = _MockMacOSSort();
      final delegate = MacOSDelegate();
      await delegate.init(
        SortOptions(
          macOS: SortOptionsMacOS(
            direction: SortDirection.descending,
            sort: mockSort,
          ),
        ),
      );

      final result = await delegate.sort([
        const SortItem(id: 'a', value: 'hello'),
      ]);
      expect(result, [const SortItem(id: 'a', value: 'hello')]);
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('init defaults direction to ascending', () async {
      final mockSort = _MockMacOSSort();
      final delegate = MacOSDelegate();
      await delegate.init(SortOptions(macOS: SortOptionsMacOS(sort: mockSort)));

      await delegate.sort([const SortItem(id: 'x', value: 'y')]);
      expect(mockSort.lastDirection, SortDirection.ascending);
    });

    test('init creates default MacOSSort when none provided', () async {
      final delegate = MacOSDelegate();
      await delegate.init(const SortOptions());
    });

    test('sort maps SortItem to CollationMacOSItem and back', () async {
      final mockSort = _MockMacOSSort();
      final delegate = MacOSDelegate();
      await delegate.init(SortOptions(macOS: SortOptionsMacOS(sort: mockSort)));

      final result = await delegate.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'apple'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2']);
    });

    test('sort overrides direction from call argument', () async {
      final mockSort = _MockMacOSSort();
      final delegate = MacOSDelegate();
      await delegate.init(SortOptions(macOS: SortOptionsMacOS(sort: mockSort)));

      await delegate.sort([
        const SortItem(id: 'a', value: 'x'),
      ], direction: SortDirection.descending);
      expect(mockSort.lastDirection, SortDirection.descending);
    });
  });
}

class _MockMacOSSort implements MacOSSort {
  SortDirection? lastDirection;

  @override
  Future<List<CollationMacOSItem>> sort(
    List<CollationMacOSItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) async {
    lastDirection = direction;
    return items;
  }
}
