import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

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
      final result = await delegate.sort([const SortItem(id: 'a', value: 'x')]);
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

      await delegate.sort(
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

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastLocale, const Locale('ja'));
      expect(mockSort.lastDirection, SortDirection.descending);
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
  IcuCollationEngine engine(String? localeName) => _MockEngine();

  @override
  void dispose() {}
}

class _MockEngine implements IcuCollationEngine {
  @override
  int compare(String a, String b) => a.compareTo(b);

  @override
  void dispose() {}
}

class _MockLinuxSort implements LinuxSort {
  Locale? lastLocale;
  SortDirection? lastDirection;

  @override
  bool get isAvailable => true;

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) async {
    lastLocale = locale;
    lastDirection = direction;
    return items;
  }
}
