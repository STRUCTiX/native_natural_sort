import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  group('WindowsDelegate', () {
    test('init resolves loader and stores locale/backend/direction', () async {
      final mockLoader = _MockLoader();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            locale: const Locale('de'),
            backend: WindowsCollationBackend.ffi,
            direction: SortDirection.descending,
            loader: mockLoader,
          ),
        ),
      );

      expect(mockLoader.initCalled, isTrue);
    });

    test('init creates default loader when none provided', () async {
      final delegate = WindowsDelegate();
      await delegate.init(const SortOptions());
    });

    test('sort maps SortItem to CollationWindowsItem and back', () async {
      final mockSort = _MockWindowsSort();
      final mockLoader = _MockLoader();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(loader: mockLoader, sort: mockSort),
        ),
      );

      final result = await delegate.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'apple'),
      ]);
      expect(result.map((i) => i.id), mockSort.lastRequestedIds);
    });

    test('sort passes backend from options to WindowsSort', () async {
      final mockSort = _MockWindowsSort();
      final mockLoader = _MockLoader();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
            loader: mockLoader,
            sort: mockSort,
            backend: WindowsCollationBackend.ffi,
          ),
        ),
      );

      await delegate.sort([const SortItem(id: 'a', value: 'x')]);
      expect(mockSort.lastBackend, WindowsCollationBackend.ffi);
    });

    test('sort overrides locale and direction from call arguments', () async {
      final mockSort = _MockWindowsSort();
      final mockLoader = _MockLoader();
      final delegate = WindowsDelegate();
      await delegate.init(
        SortOptions(
          windows: SortOptionsWindows(
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

class _MockWindowsSort implements WindowsSort {
  Locale? lastLocale;
  SortDirection? lastDirection;
  WindowsCollationBackend? lastBackend;
  List<String> lastRequestedIds = [];

  @override
  bool get isFfiAvailable => true;

  @override
  Future<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    WindowsCollationBackend? backend,
    SortDirection? direction,
  }) async {
    lastLocale = locale;
    lastDirection = direction;
    lastBackend = backend;
    lastRequestedIds = items.map((i) => i.id).toList();
    return items;
  }
}
