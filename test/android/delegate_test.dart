import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('AndroidDelegate', () {
    test('init stores locale, direction, and sort from options', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(
          android: SortOptionsAndroid(
            locale: const Locale('zh'),
            direction: SortDirection.descending,
            sort: mockSort,
          ),
        ),
      );

      final result = await delegate.sort([
        const SortItem(id: 'a', value: 'hello'),
      ]);
      expect(result, [const SortItem(id: 'a', value: 'hello')]);
      expect(mockSort.lastLocale, const Locale('zh'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('init defaults direction to ascending when not specified', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(android: SortOptionsAndroid(sort: mockSort)),
      );

      await delegate.sort([const SortItem(id: 'x', value: 'y')]);
      expect(mockSort.lastDirection, SortDirection.ascending);
    });

    test('init creates default AndroidSort when none provided', () async {
      final delegate = AndroidDelegate();
      await delegate.init(const SortOptions());
      // No crash → default sort was created.
    });

    test('sort maps SortItem to CollationAndroidItem and back', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(android: SortOptionsAndroid(sort: mockSort)),
      );

      final result = await delegate.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'apple'),
      ]);
      expect(result.map((i) => i.id), mockSort.lastRequestedIds);
    });

    test('sort overrides locale and direction from call arguments', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(
          android: SortOptionsAndroid(
            locale: const Locale('en'),
            sort: mockSort,
          ),
        ),
      );

      await delegate.sort(
        [const SortItem(id: 'a', value: 'x')],
        locale: const Locale('fr'),
        direction: SortDirection.descending,
      );
      expect(mockSort.lastLocale, const Locale('fr'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('init stores collator fields from options', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(
          android: SortOptionsAndroid(
            sort: mockSort,
            strength: CollatorStrength.primary,
            decomposition: CollatorDecomposition.none,
            numeric: false,
          ),
        ),
      );

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastStrength, CollatorStrength.primary);
      expect(mockSort.lastDecomposition, CollatorDecomposition.none);
      expect(mockSort.lastNumeric, false);
    });

    test('sort passes direction to AndroidSort', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(android: SortOptionsAndroid(sort: mockSort)),
      );

      await delegate.sort([
        const SortItem(id: 'a', value: 'x'),
      ], direction: SortDirection.descending);
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('sortWithOptions overrides collator fields per-call', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(
          android: SortOptionsAndroid(
            sort: mockSort,
            strength: CollatorStrength.tertiary,
            numeric: true,
          ),
        ),
      );

      await delegate.sortWithOptions(
        [const SortItem(id: 'a', value: 'x')],
        strength: CollatorStrength.primary,
        numeric: false,
      );
      expect(mockSort.lastStrength, CollatorStrength.primary);
      expect(mockSort.lastNumeric, false);
    });

    test('sortWithOptions falls back to defaults when param is null', () async {
      final mockSort = _MockAndroidSort();
      final delegate = AndroidDelegate();
      await delegate.init(
        SortOptions(
          android: SortOptionsAndroid(
            sort: mockSort,
            decomposition: CollatorDecomposition.none,
          ),
        ),
      );

      await delegate.sortWithOptions([
        const SortItem(id: 'a', value: 'x'),
      ], direction: SortDirection.descending);
      expect(mockSort.lastDecomposition, CollatorDecomposition.none);
      expect(mockSort.lastDirection, SortDirection.descending);
    });
  });
}

class _MockAndroidSort implements AndroidSort {
  Locale? lastLocale;
  SortDirection? lastDirection;
  CollatorStrength? lastStrength;
  CollatorDecomposition? lastDecomposition;
  bool? lastNumeric;
  List<String> lastRequestedIds = [];

  @override
  Future<List<CollationAndroidItem>> sort(
    List<CollationAndroidItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) async {
    lastLocale = locale;
    lastDirection = direction;
    lastStrength = strength;
    lastDecomposition = decomposition;
    lastNumeric = numeric;
    lastRequestedIds = items.map((i) => i.id).toList();
    return items;
  }
}
