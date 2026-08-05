import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/native_natural_sort_io.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SortDirection', () {
    test('has ascending and descending values', () {
      expect(SortDirection.values, [
        SortDirection.ascending,
        SortDirection.descending,
      ]);
    });
  });

  group('SortItem', () {
    test('equality by id and value', () {
      const a = SortItem(id: 'a', value: 'x');
      const b = SortItem(id: 'a', value: 'x');
      const c = SortItem(id: 'a', value: 'y');
      const d = SortItem(id: 'b', value: 'x');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('hashCode matches equality', () {
      const a = SortItem(id: 'a', value: 'x');
      const b = SortItem(id: 'a', value: 'x');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes id and value', () {
      expect(
        const SortItem(id: 'a', value: 'hello').toString(),
        'SortItem(id: a, value: hello)',
      );
    });
  });

  group('SortOptions', () {
    test('constructs with all fields null by default', () {
      const options = SortOptions();
      expect(options.android, isNull);
      expect(options.ios, isNull);
      expect(options.macOS, isNull);
      expect(options.linux, isNull);
      expect(options.windows, isNull);
      expect(options.web, isNull);
    });

    test('per-platform direction defaults to ascending', () {
      expect(const SortOptionsAndroid().direction, SortDirection.ascending);
      expect(const SortOptionsIOS().direction, SortDirection.ascending);
      expect(const SortOptionsMacOS().direction, SortDirection.ascending);
      expect(const SortOptionsLinux().direction, SortDirection.ascending);
      expect(const SortOptionsWindows().direction, SortDirection.ascending);
      expect(const SortOptionsWeb().direction, SortDirection.ascending);
    });

    test('per-platform options are preserved', () {
      final options = SortOptions(
        android: const SortOptionsAndroid(locale: Locale('zh')),
        ios: const SortOptionsIOS(
          locale: Locale('ja'),
          direction: SortDirection.descending,
          caseSensitive: true,
        ),
        macOS: const SortOptionsMacOS(
          locale: Locale('ko'),
          direction: SortDirection.descending,
          diacriticInsensitive: true,
        ),
        linux: const SortOptionsLinux(locale: Locale('de')),
        windows: SortOptionsWindows(
          locale: const Locale('en'),
          sort: WindowsSort.ffi(),
        ),
        web: const SortOptionsWeb(locale: Locale('en')),
      );
      expect(options.android?.locale, const Locale('zh'));
      expect(options.ios?.locale, const Locale('ja'));
      expect(options.ios?.direction, SortDirection.descending);
      expect(options.ios?.caseSensitive, true);
      expect(options.macOS?.locale, const Locale('ko'));
      expect(options.macOS?.direction, SortDirection.descending);
      expect(options.macOS?.diacriticInsensitive, true);
      expect(options.linux?.locale, const Locale('de'));
      expect(options.windows?.locale, const Locale('en'));
      expect(options.windows?.sort, isA<WindowsSort>());
      expect(options.web?.locale, const Locale('en'));
    });

    test('SortOptionsAndroid stores collator fields', () {
      const options = SortOptionsAndroid(
        strength: CollatorStrength.primary,
        decomposition: CollatorDecomposition.none,
        numeric: false,
      );
      expect(options.strength, CollatorStrength.primary);
      expect(options.decomposition, CollatorDecomposition.none);
      expect(options.numeric, false);
    });

    test('SortOptionsAndroid collator fields default to null', () {
      const options = SortOptionsAndroid();
      expect(options.strength, isNull);
      expect(options.decomposition, isNull);
      expect(options.numeric, isNull);
    });

    test('SortOptionsIOS stores caseSensitive and diacriticInsensitive', () {
      const options = SortOptionsIOS(
        caseSensitive: true,
        diacriticInsensitive: true,
      );
      expect(options.caseSensitive, true);
      expect(options.diacriticInsensitive, true);
    });

    test('SortOptionsIOS stores locale', () {
      const options = SortOptionsIOS(locale: Locale('fr'));
      expect(options.locale, const Locale('fr'));
    });

    test('SortOptionsIOS locale defaults to null', () {
      const options = SortOptionsIOS();
      expect(options.locale, isNull);
    });

    test(
      'SortOptionsIOS caseSensitive/diacriticInsensitive default to null',
      () {
        const options = SortOptionsIOS();
        expect(options.caseSensitive, isNull);
        expect(options.diacriticInsensitive, isNull);
      },
    );

    test('SortOptionsMacOS stores caseSensitive and diacriticInsensitive', () {
      const options = SortOptionsMacOS(
        caseSensitive: true,
        diacriticInsensitive: true,
      );
      expect(options.caseSensitive, true);
      expect(options.diacriticInsensitive, true);
    });

    test('SortOptionsMacOS stores locale', () {
      const options = SortOptionsMacOS(locale: Locale('fr'));
      expect(options.locale, const Locale('fr'));
    });

    test('SortOptionsMacOS locale defaults to null', () {
      const options = SortOptionsMacOS();
      expect(options.locale, isNull);
    });

    test(
      'SortOptionsMacOS caseSensitive/diacriticInsensitive default to null',
      () {
        const options = SortOptionsMacOS();
        expect(options.caseSensitive, isNull);
        expect(options.diacriticInsensitive, isNull);
      },
    );

    test('SortOptionsLinux stores strength, decomposition, numeric', () {
      const options = SortOptionsLinux(
        strength: CollatorStrength.primary,
        decomposition: CollatorDecomposition.none,
        numeric: false,
      );
      expect(options.strength, CollatorStrength.primary);
      expect(options.decomposition, CollatorDecomposition.none);
      expect(options.numeric, false);
    });

    test('SortOptionsLinux strength/decomposition/numeric default to null', () {
      const options = SortOptionsLinux();
      expect(options.strength, isNull);
      expect(options.decomposition, isNull);
      expect(options.numeric, isNull);
    });

    test('SortOptionsLinux stores locale', () {
      const options = SortOptionsLinux(locale: Locale('de'));
      expect(options.locale, const Locale('de'));
    });

    test('SortOptionsLinux locale defaults to null', () {
      const options = SortOptionsLinux();
      expect(options.locale, isNull);
    });

    test('SortOptionsWeb stores strength, decomposition, numeric', () {
      const options = SortOptionsWeb(
        strength: CollatorStrength.primary,
        decomposition: CollatorDecomposition.none,
        numeric: false,
      );
      expect(options.strength, CollatorStrength.primary);
      expect(options.decomposition, CollatorDecomposition.none);
      expect(options.numeric, false);
    });

    test('SortOptionsWeb strength/decomposition/numeric default to null', () {
      const options = SortOptionsWeb();
      expect(options.strength, isNull);
      expect(options.decomposition, isNull);
      expect(options.numeric, isNull);
    });

    test('SortOptionsWeb stores locale', () {
      const options = SortOptionsWeb(locale: Locale('en'));
      expect(options.locale, const Locale('en'));
    });

    test('SortOptionsWeb locale defaults to null', () {
      const options = SortOptionsWeb();
      expect(options.locale, isNull);
    });
  });

  group('CollatorStrength', () {
    test('has four levels in order', () {
      expect(CollatorStrength.values, [
        CollatorStrength.primary,
        CollatorStrength.secondary,
        CollatorStrength.tertiary,
        CollatorStrength.identical,
      ]);
    });

    test('value matches transport encoding', () {
      expect(CollatorStrength.primary.value, 0);
      expect(CollatorStrength.secondary.value, 1);
      expect(CollatorStrength.tertiary.value, 2);
      expect(CollatorStrength.identical.value, 3);
    });
  });

  group('CollatorDecomposition', () {
    test('has three modes in order', () {
      expect(CollatorDecomposition.values, [
        CollatorDecomposition.none,
        CollatorDecomposition.canonical,
        CollatorDecomposition.full,
      ]);
    });

    test('value matches transport encoding', () {
      expect(CollatorDecomposition.none.value, 0);
      expect(CollatorDecomposition.canonical.value, 1);
      expect(CollatorDecomposition.full.value, 2);
    });
  });

  group('WindowsSort', () {
    test('WindowsSort.pigeon init succeeds', () async {
      final sort = WindowsSort.pigeon();
      await sort.init(); // should not throw
    });

    test('SortOptionsWindows default sort is null', () {
      expect(const SortOptionsWindows().sort, isNull);
    });

    test('SortOptionsWindows stores strength, decomposition, numeric', () {
      const options = SortOptionsWindows(
        strength: CollatorStrength.primary,
        decomposition: CollatorDecomposition.none,
        numeric: false,
      );
      expect(options.strength, CollatorStrength.primary);
      expect(options.decomposition, CollatorDecomposition.none);
      expect(options.numeric, false);
    });

    test('SortOptionsWindows FFI fields default to null', () {
      const options = SortOptionsWindows();
      expect(options.strength, isNull);
      expect(options.decomposition, isNull);
      expect(options.numeric, isNull);
    });

    test(
      'SortOptionsWindows stores caseSensitive and diacriticInsensitive',
      () {
        const options = SortOptionsWindows(
          caseSensitive: true,
          diacriticInsensitive: true,
        );
        expect(options.caseSensitive, true);
        expect(options.diacriticInsensitive, true);
      },
    );

    test(
      'SortOptionsWindows caseSensitive/diacriticInsensitive default to null',
      () {
        const options = SortOptionsWindows();
        expect(options.caseSensitive, isNull);
        expect(options.diacriticInsensitive, isNull);
      },
    );

    test('SortOptionsWindows stores locale', () {
      const options = SortOptionsWindows(locale: Locale('en'));
      expect(options.locale, const Locale('en'));
    });

    test('SortOptionsWindows locale defaults to null', () {
      const options = SortOptionsWindows();
      expect(options.locale, isNull);
    });

    test('SortOptionsWindows.ffi pre-selects FFI backend', () {
      final options = SortOptionsWindows.ffi();
      expect(options.sort, isA<WindowsSort>());
      expect(options.direction, SortDirection.ascending);
    });

    test('SortOptionsWindows.ffi exposes FFI params', () {
      final options = SortOptionsWindows.ffi(
        locale: const Locale('de'),
        direction: SortDirection.descending,
        strength: CollatorStrength.primary,
        decomposition: CollatorDecomposition.none,
        numeric: false,
      );
      expect(options.locale, const Locale('de'));
      expect(options.direction, SortDirection.descending);
      expect(options.strength, CollatorStrength.primary);
      expect(options.decomposition, CollatorDecomposition.none);
      expect(options.numeric, false);
      // Pigeon params should remain null.
      expect(options.caseSensitive, isNull);
      expect(options.diacriticInsensitive, isNull);
    });

    test('SortOptionsWindows.pigeon pre-selects Pigeon backend', () {
      final options = SortOptionsWindows.pigeon();
      expect(options.sort, isA<WindowsSort>());
      expect(options.direction, SortDirection.ascending);
    });

    test('SortOptionsWindows.pigeon exposes Pigeon params', () {
      final options = SortOptionsWindows.pigeon(
        locale: const Locale('fr'),
        direction: SortDirection.descending,
        caseSensitive: true,
        diacriticInsensitive: true,
      );
      expect(options.locale, const Locale('fr'));
      expect(options.direction, SortDirection.descending);
      expect(options.caseSensitive, true);
      expect(options.diacriticInsensitive, true);
      // FFI params should remain null.
      expect(options.strength, isNull);
      expect(options.decomposition, isNull);
      expect(options.numeric, isNull);
    });
  });

  group('NativeSort', () {
    test('sort delegates to injected service', () async {
      final mock = _MockSort([
        const SortItem(id: 'id3', value: 'apple'),
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'cherry'),
      ]);
      NativeSort.instance = mock;

      final sort = NativeSort();
      await sort.init(const SortOptions());
      final result = await sort.sort([
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'cherry'),
        const SortItem(id: 'id3', value: 'apple'),
      ]);
      expect(result, [
        const SortItem(id: 'id3', value: 'apple'),
        const SortItem(id: 'id1', value: 'banana'),
        const SortItem(id: 'id2', value: 'cherry'),
      ]);

      NativeSort.instance = null;
    });

    test('init is idempotent — second call is a no-op', () async {
      final initCalls = <SortOptions>[];
      final mock = _ContractMock(initTracking: initCalls);
      NativeSort.instance = mock;

      final sort = NativeSort();
      await sort.init(const SortOptions(android: SortOptionsAndroid()));
      await sort.init(const SortOptions(linux: SortOptionsLinux()));

      expect(initCalls.length, 1);
      NativeSort.instance = null;
    });

    test('concurrent init calls are deduped', () async {
      final initCalls = <SortOptions>[];
      final mock = _ContractMock(initTracking: initCalls);
      NativeSort.instance = mock;

      final sort = NativeSort();
      final f1 = sort.init(const SortOptions());
      final f2 = sort.init(const SortOptions());
      await Future.wait([f1, f2]);

      expect(initCalls.length, 1);
      NativeSort.instance = null;
    });

    test('sort throws StateError before init', () {
      final mock = _ContractMock();
      NativeSort.instance = mock;
      final sort = NativeSort();
      expect(
        () => sort.sort([const SortItem(id: 'a', value: 'x')]),
        throwsStateError,
      );
      NativeSort.instance = null;
    });

    test('factory returns the same instance when no mock is set', () {
      NativeSort.instance = null;
      final a = NativeSort();
      final b = NativeSort();
      expect(identical(a, b), isTrue);
    });

    test('instance setter replaces the singleton for testing', () {
      NativeSort.instance = null;
      final real = NativeSort();
      final mock = _MockSort([]);
      NativeSort.instance = mock;
      expect(NativeSort(), same(mock));
      NativeSort.instance = null;
      expect(NativeSort(), same(real));
    });

    test('init rethrows delegate errors and allows retry', () async {
      final mock = _ContractMock(failCount: 1);
      NativeSort.instance = mock;

      final sort = NativeSort();
      await expectLater(
        sort.init(const SortOptions()),
        throwsA(isA<Exception>()),
      );

      // Second init should succeed (mock was configured to fail once).
      await sort.init(const SortOptions());
      expect(mock.initCallCount, 2);

      NativeSort.instance = null;
    });

    test('resolveAs returns PlatformDelegate', () {
      NativeSort.instance = null;
      final sort = NativeSort();
      final delegate = sort.resolveAs<PlatformDelegate>();
      expect(delegate, isA<PlatformDelegate>());
    });

    test('resolveAs returns platform-specific delegate type', () {
      NativeSort.instance = null;
      final sort = NativeSort();
      final delegate = sort.resolveAs<PlatformDelegate>();
      // The delegate must be one of the known platform delegates.
      expect(
        delegate,
        anyOf(
          isA<AndroidDelegate>(),
          isA<IOSDelegate>(),
          isA<MacOSDelegate>(),
          isA<LinuxDelegate>(),
          isA<WindowsDelegate>(),
          isA<WebDelegate>(),
        ),
      );
    });

    test('android extension resolves on Android platform', () {
      NativeSort.instance = null;
      final sort = NativeSort();
      if (defaultTargetPlatform == TargetPlatform.android) {
        expect(sort.android, isA<AndroidDelegate>());
      }
    });
  });
}

class _MockSort implements NativeSort {
  final List<SortItem> _result;

  _MockSort(this._result);

  @override
  Future<void> init(SortOptions options) async {}

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async => _result;

  @override
  Future<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) async => _result;

  @override
  T resolveAs<T extends PlatformDelegate>() => this as T;
}

/// Mirrors [NativeSort._] init/sort contract: idempotent init,
/// concurrent dedup, StateError before init, retry on failure.
class _ContractMock implements NativeSort {
  final List<SortItem> _result;
  final List<SortOptions>? _initTracking;
  final int _failCount;

  bool _initialized = false;
  int _initCallCount = 0;
  Future<void>? _initFuture;

  _ContractMock({
    List<SortItem> result = const [],
    List<SortOptions>? initTracking,
    int failCount = 0,
  }) : _result = result,
       _initTracking = initTracking,
       _failCount = failCount;

  int get initCallCount => _initCallCount;

  @override
  Future<void> init(SortOptions options) async {
    if (_initialized) return;
    if (_initFuture != null) return _initFuture!;

    _initFuture = () async {
      _initCallCount++;
      _initTracking?.add(options);
      if (_initCallCount <= _failCount) {
        throw Exception('init failure $_initCallCount');
      }
      _initialized = true;
    }();

    try {
      await _initFuture;
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) {
    if (!_initialized) throw StateError('Call init() first');
    return Future.value(_result);
  }

  @override
  Future<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) {
    if (!_initialized) throw StateError('Call init() first');
    return Future.value(_result);
  }

  @override
  T resolveAs<T extends PlatformDelegate>() => this as T;
}
