import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('WindowsDelegate', () {
    test('init creates default sort when none provided', () async {
      final delegate = WindowsDelegate();
      await delegate.init(const SortOptions());
    });

    test('init calls sort.init()', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(windows: SortOptionsWindows(sort: mockSort)),
      );
      expect(mockSort.initCalled, isTrue);
    });

    test('init stores locale and direction from options', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            locale: const Locale('de'),
            direction: SortDirection.descending,
            sort: mockSort,
          ),
        ),
      );

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, const Locale('de'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('sort maps SortItem to CollationWindowsItem and back', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(windows: SortOptionsWindows(sort: mockSort)),
      );

      final result = await delegate.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'apple'),
      ]);
      expect(result.map((i) => i.id), mockSort.lastRequestedIds);
    });

    test('sort overrides locale and direction from call arguments', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
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

    test('sortWithOptions overrides per-call', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            locale: const Locale('ja'),
            direction: SortDirection.descending,
            sort: mockSort,
          ),
        ),
      );

      await delegate.sortWithOptions(
        [const SortItem(id: 'a', value: 'x')],
        options: const SortOptions(
          windows: SortOptionsWindows(direction: SortDirection.ascending),
        ),
      );
      expect(mockSort.lastLocale, const Locale('ja'));
      expect(mockSort.lastDirection, SortDirection.ascending);
    });

    test('sortWithOptions with null options uses init defaults', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            locale: const Locale('es'),
            direction: SortDirection.descending,
            sort: mockSort,
          ),
        ),
      );

      await delegate.sortWithOptions([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, const Locale('es'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('sortWithOptions with empty list does not throw', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(windows: SortOptionsWindows(sort: mockSort)),
      );

      final result = await delegate.sortWithOptions([]);
      expect(result, isEmpty);
    });

    test('init stores FFI tuning params from options', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
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

    test('init stores Pigeon tuning params from options', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            sort: mockSort,
            caseSensitive: true,
            diacriticInsensitive: true,
          ),
        ),
      );

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastCaseSensitive, true);
      expect(mockSort.lastDiacriticInsensitive, true);
    });

    test('sortWithOptions overrides tuning params per-call', () async {
      final mockSort = _MockWindowsSort();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            sort: mockSort,
            strength: CollatorStrength.tertiary,
            numeric: true,
            caseSensitive: false,
          ),
        ),
      );

      await delegate.sortWithOptions(
        [const SortItem(id: 'a', value: 'x')],
        options: const SortOptions(
          windows: SortOptionsWindows(
            strength: CollatorStrength.primary,
            numeric: false,
            caseSensitive: true,
          ),
        ),
      );
      expect(mockSort.lastStrength, CollatorStrength.primary);
      expect(mockSort.lastNumeric, false);
      expect(mockSort.lastCaseSensitive, true);
    });

    test(
      'sortWithOptions falls back to init defaults for tuning params',
      () async {
        final mockSort = _MockWindowsSort();
        final delegate = WindowsDelegate();
        await delegate.init(
          SortOptions(
            windows: SortOptionsWindows(
              sort: mockSort,
              decomposition: CollatorDecomposition.none,
              diacriticInsensitive: true,
            ),
          ),
        );

        await delegate.sortWithOptions(
          [const SortItem(id: 'a', value: 'x')],
          options: const SortOptions(
            windows: SortOptionsWindows(direction: SortDirection.descending),
          ),
        );
        expect(mockSort.lastDecomposition, CollatorDecomposition.none);
        expect(mockSort.lastDiacriticInsensitive, true);
        expect(mockSort.lastDirection, SortDirection.descending);
      },
    );
  });
}

class _MockWindowsSort implements WindowsSort {
  bool initCalled = false;
  Locale? lastLocale;
  SortDirection? lastDirection;
  CollatorStrength? lastStrength;
  CollatorDecomposition? lastDecomposition;
  bool? lastNumeric;
  bool? lastCaseSensitive;
  bool? lastDiacriticInsensitive;
  List<String> lastRequestedIds = [];

  @override
  bool get isAvailable => true;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) async {
    lastLocale = locale;
    lastDirection = direction;
    lastStrength = strength;
    lastDecomposition = decomposition;
    lastNumeric = numeric;
    lastCaseSensitive = caseSensitive;
    lastDiacriticInsensitive = diacriticInsensitive;
    lastRequestedIds = items.map((i) => i.id).toList();
    return items;
  }
}
