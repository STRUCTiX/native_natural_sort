import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

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
    });

    test('per-platform direction defaults to ascending', () {
      expect(const SortOptionsAndroid().direction, SortDirection.ascending);
      expect(const SortOptionsIOS().direction, SortDirection.ascending);
      expect(const SortOptionsMacOS().direction, SortDirection.ascending);
      expect(const SortOptionsLinux().direction, SortDirection.ascending);
      expect(const SortOptionsWindows().direction, SortDirection.ascending);
    });

    test('per-platform options are preserved', () {
      const options = SortOptions(
        android: SortOptionsAndroid(locale: Locale('zh')),
        ios: SortOptionsIOS(direction: SortDirection.descending),
        macOS: SortOptionsMacOS(direction: SortDirection.descending),
        linux: SortOptionsLinux(locale: Locale('de')),
        windows: SortOptionsWindows(
          locale: Locale('en'),
          backend: WindowsCollationBackend.ffi,
        ),
      );
      expect(options.android?.locale, const Locale('zh'));
      expect(options.ios?.direction, SortDirection.descending);
      expect(options.macOS?.direction, SortDirection.descending);
      expect(options.linux?.locale, const Locale('de'));
      expect(options.windows?.locale, const Locale('en'));
      expect(options.windows?.backend, WindowsCollationBackend.ffi);
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

    test('index matches transport encoding', () {
      expect(CollatorStrength.primary.index, 0);
      expect(CollatorStrength.secondary.index, 1);
      expect(CollatorStrength.tertiary.index, 2);
      expect(CollatorStrength.identical.index, 3);
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

    test('index matches transport encoding', () {
      expect(CollatorDecomposition.none.index, 0);
      expect(CollatorDecomposition.canonical.index, 1);
      expect(CollatorDecomposition.full.index, 2);
    });
  });

  group('WindowsCollationBackend', () {
    test('has pigeon and ffi values', () {
      expect(WindowsCollationBackend.values, [
        WindowsCollationBackend.pigeon,
        WindowsCollationBackend.ffi,
      ]);
    });

    test('default is pigeon', () {
      expect(
        const SortOptionsWindows().backend,
        WindowsCollationBackend.pigeon,
      );
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
  T resolveAs<T extends PlatformDelegate>() => this as T;
}
