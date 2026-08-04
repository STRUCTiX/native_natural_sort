import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/native_natural_sort_io.dart';

void main() {
  group('LinuxDelegate', () {
    test('init resolves loader and stores locale/direction', () async {
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(
          linux: SortOptionsLinux(
            locale: const Locale('de'),
            direction: SortDirection.descending,
            loader: mockLoader,
          ),
        ),
      );

      expect(mockLoader.initCalled, isTrue);
      final result = delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(result, [const SortItem(id: 'a', value: 'x')]);
    });

    test('init creates default loader and sort when none provided', () async {
      final delegate = LinuxDelegate();
      await delegate.init(const SortOptions());
    });

    test('sort overrides locale and direction from call arguments', () async {
      final mockSort = _MockLinuxSort();
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(
          linux: SortOptionsLinux(
            locale: const Locale('en'),
            loader: mockLoader,
            sort: mockSort,
          ),
        ),
      );

      delegate.sort(
        [const SortItem(id: 'a', value: 'x')],
        locale: const Locale('fr'),
        direction: SortDirection.descending,
      );
      expect(mockSort.lastLocale, const Locale('fr'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('sort uses defaults when call arguments are omitted', () async {
      final mockSort = _MockLinuxSort();
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(
          linux: SortOptionsLinux(
            locale: const Locale('ja'),
            direction: SortDirection.descending,
            loader: mockLoader,
            sort: mockSort,
          ),
        ),
      );

      delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, const Locale('ja'));
      expect(mockSort.lastDirection, SortDirection.descending);
    });

    test('sortWithOptions overrides all collator parameters', () async {
      final mockSort = _MockLinuxSort();
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(
          linux: SortOptionsLinux(
            locale: const Locale('en'),
            loader: mockLoader,
            sort: mockSort,
          ),
        ),
      );

      delegate.sortWithOptions(
        [const SortItem(id: 'a', value: 'x')],
        options: const SortOptions(
          linux: SortOptionsLinux(
            locale: Locale('fr'),
            direction: SortDirection.descending,
            strength: CollatorStrength.primary,
            decomposition: CollatorDecomposition.none,
            numeric: false,
          ),
        ),
      );
      expect(mockSort.lastLocale, const Locale('fr'));
      expect(mockSort.lastDirection, SortDirection.descending);
      expect(mockSort.lastStrength, CollatorStrength.primary);
      expect(mockSort.lastDecomposition, CollatorDecomposition.none);
      expect(mockSort.lastNumeric, false);
    });

    test(
      'sortWithOptions falls back to init defaults when params are null',
      () async {
        final mockSort = _MockLinuxSort();
        final mockLoader = _MockLoader();
        final delegate = LinuxDelegate();
        await delegate.init(
          SortOptions(
            linux: SortOptionsLinux(
              locale: const Locale('ja'),
              direction: SortDirection.descending,
              strength: CollatorStrength.secondary,
              decomposition: CollatorDecomposition.full,
              numeric: false,
              loader: mockLoader,
              sort: mockSort,
            ),
          ),
        );

        delegate.sortWithOptions(
          [const SortItem(id: 'a', value: 'x')],
          // Only override strength, others should fall back.
          options: const SortOptions(
            linux: SortOptionsLinux(strength: CollatorStrength.primary),
          ),
        );
        expect(mockSort.lastLocale, const Locale('ja'));
        expect(mockSort.lastDirection, SortDirection.ascending);
        expect(mockSort.lastStrength, CollatorStrength.primary);
        expect(mockSort.lastDecomposition, CollatorDecomposition.full);
        expect(mockSort.lastNumeric, false);
      },
    );

    test(
      'sort passes strength, decomposition, numeric from init defaults',
      () async {
        final mockSort = _MockLinuxSort();
        final mockLoader = _MockLoader();
        final delegate = LinuxDelegate();
        await delegate.init(
          SortOptions(
            linux: SortOptionsLinux(
              strength: CollatorStrength.identical,
              decomposition: CollatorDecomposition.canonical,
              numeric: false,
              loader: mockLoader,
              sort: mockSort,
            ),
          ),
        );

        delegate.sort([const SortItem(id: 'a', value: 'x')]);
        expect(mockSort.lastStrength, CollatorStrength.identical);
        expect(mockSort.lastDecomposition, CollatorDecomposition.canonical);
        expect(mockSort.lastNumeric, false);
      },
    );

    test('empty list with descending direction does not throw', () async {
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(linux: SortOptionsLinux(loader: mockLoader)),
      );

      final result = delegate.sort([], direction: SortDirection.descending);
      expect(result, isEmpty);
    });

    test('single element with descending direction does not throw', () async {
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(linux: SortOptionsLinux(loader: mockLoader)),
      );

      final result = delegate.sort([
        const SortItem(id: 'only', value: 'x'),
      ], direction: SortDirection.descending);
      expect(result, [const SortItem(id: 'only', value: 'x')]);
    });

    test('sortWithOptions with empty list does not throw', () async {
      final mockLoader = _MockLoader();
      final delegate = LinuxDelegate();
      await delegate.init(
        SortOptions(linux: SortOptionsLinux(loader: mockLoader)),
      );

      final result = delegate.sortWithOptions(
        [],
        options: const SortOptions(linux: SortOptionsLinux(numeric: false)),
      );
      expect(result, isEmpty);
    });
  });
}

class _MockLoader implements CollationLibraryLoader {
  bool initCalled = false;

  @override
  bool get isAvailable => true;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  IcuCollator collator(
    String? localeName, {
    bool numeric = true,
    int? strength,
    int? decomposition,
  }) => _MockCollator();

  @override
  void dispose() {}
}

class _MockCollator implements IcuCollator {
  @override
  int compare(String a, String b) => a.compareTo(b);

  @override
  void dispose() {}
}

class _MockLinuxSort implements LinuxSort {
  Locale? lastLocale;
  SortDirection? lastDirection;
  CollatorStrength? lastStrength;
  CollatorDecomposition? lastDecomposition;
  bool? lastNumeric;

  @override
  bool get isAvailable => true;

  @override
  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) {
    lastLocale = locale;
    lastDirection = direction;
    lastStrength = strength;
    lastDecomposition = decomposition;
    lastNumeric = numeric;
    return items;
  }
}
