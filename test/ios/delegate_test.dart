import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('IOSDelegate', () {
    test('init stores direction and sort from options', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(
        SortOptions(
          ios: SortOptionsIOS(
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
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(SortOptions(ios: SortOptionsIOS(sort: mockSort)));

      await delegate.sort([const SortItem(id: 'x', value: 'y')]);
      expect(mockSort.lastDirection, SortDirection.ascending);
    });

    test('init creates default IOSSort when none provided', () async {
      final delegate = IOSDelegate();
      await delegate.init(const SortOptions());
      // No crash.
    });

    test('sort maps SortItem to CollationIOSItem and back', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(SortOptions(ios: SortOptionsIOS(sort: mockSort)));

      final result = await delegate.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'apple'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2']);
    });

    test('sort overrides direction from call argument', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(SortOptions(ios: SortOptionsIOS(sort: mockSort)));

      await delegate.sort([
        const SortItem(id: 'a', value: 'x'),
      ], direction: SortDirection.descending);
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test(
      'init stores caseSensitive and diacriticInsensitive from options',
      () async {
        final mockSort = _MockIOSSort();
        final delegate = IOSDelegate();
        await delegate.init(
          SortOptions(
            ios: SortOptionsIOS(
              sort: mockSort,
              caseSensitive: true,
              diacriticInsensitive: true,
            ),
          ),
        );

        await delegate.sort([const SortItem(id: 'a', value: 'x')]);
        expect(mockSort.lastCaseSensitive, true);
        expect(mockSort.lastDiacriticInsensitive, true);
      },
    );

    test(
      'init defaults caseSensitive and diacriticInsensitive to null',
      () async {
        final mockSort = _MockIOSSort();
        final delegate = IOSDelegate();
        await delegate.init(SortOptions(ios: SortOptionsIOS(sort: mockSort)));

        await delegate.sort([const SortItem(id: 'a', value: 'x')]);
        expect(mockSort.lastCaseSensitive, isNull);
        expect(mockSort.lastDiacriticInsensitive, isNull);
      },
    );

    test(
      'sort passes caseSensitive and diacriticInsensitive through',
      () async {
        final mockSort = _MockIOSSort();
        final delegate = IOSDelegate();
        await delegate.init(
          SortOptions(
            ios: SortOptionsIOS(
              sort: mockSort,
              caseSensitive: false,
              diacriticInsensitive: false,
            ),
          ),
        );

        await delegate.sort([const SortItem(id: 'a', value: 'x')]);
        expect(mockSort.lastCaseSensitive, false);
        expect(mockSort.lastDiacriticInsensitive, false);
      },
    );

    test('init stores locale from options', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(
        SortOptions(
          ios: SortOptionsIOS(sort: mockSort, locale: const Locale('zh')),
        ),
      );

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, const Locale('zh'));
    });

    test('init defaults locale to null', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(SortOptions(ios: SortOptionsIOS(sort: mockSort)));

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, isNull);
    });

    test('sort overrides locale from call argument', () async {
      final mockSort = _MockIOSSort();
      final delegate = IOSDelegate();
      await delegate.init(
        SortOptions(
          ios: SortOptionsIOS(sort: mockSort, locale: const Locale('en')),
        ),
      );

      await delegate.sort([
        const SortItem(id: 'a', value: 'x'),
      ], locale: const Locale('fr'));
      expect(mockSort.lastLocale, const Locale('fr'));
    });
  });
}

class _MockIOSSort implements IOSSort {
  Locale? lastLocale;
  SortDirection? lastDirection;
  bool? lastCaseSensitive;
  bool? lastDiacriticInsensitive;

  @override
  Future<List<CollationIOSItem>> sort(
    List<CollationIOSItem> items, {
    Locale? locale,
    SortDirection? direction,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) async {
    lastLocale = locale;
    lastDirection = direction;
    lastCaseSensitive = caseSensitive;
    lastDiacriticInsensitive = diacriticInsensitive;
    return items;
  }
}
