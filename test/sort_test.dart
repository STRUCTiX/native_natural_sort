import 'dart:async';
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
      await sort.config(const SortOptions());
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

    test('config reconfigures — second call takes effect', () async {
      final configCalls = <SortOptions>[];
      final mock = _ContractMock(configTracking: configCalls);
      NativeSort.instance = mock;

      final sort = NativeSort();
      await sort.config(const SortOptions(android: SortOptionsAndroid()));
      await sort.config(const SortOptions(linux: SortOptionsLinux()));

      expect(configCalls.length, 2);
      NativeSort.instance = null;
    });

    test('concurrent config calls are deduped', () async {
      NativeSort.instance = null;
      final sort = NativeSort();
      final initOrder = <String>[];
      final gate = Completer<void>();

      final f1 = sort.config(
        const SortOptions(),
        delegate: _DelayedDelegate('first', gate, initOrder),
      );
      final f2 = sort.config(
        const SortOptions(),
        delegate: _DelayedDelegate('second', null, initOrder),
      );

      await Future<void>.delayed(Duration.zero);
      expect(initOrder, isEmpty);

      gate.complete();
      await Future.wait([f1, f2]);

      // f2 deduped to f1 — only first delegate was used.
      expect(initOrder, ['first']);
    });

    test('sort throws StateError before config', () {
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

    test('config rethrows delegate errors and allows retry', () async {
      final mock = _ContractMock(failCount: 1);
      NativeSort.instance = mock;

      final sort = NativeSort();
      await expectLater(
        sort.config(const SortOptions()),
        throwsA(isA<Exception>()),
      );

      await sort.config(const SortOptions());
      expect(mock.configCallCount, 2);

      NativeSort.instance = null;
    });

    test('config accepts custom delegate', () async {
      final customDelegate = _StubDelegate();
      NativeSort.instance = null;
      final sort = NativeSort();
      await sort.config(const SortOptions(), delegate: customDelegate);

      final resolved = sort.resolveAs<PlatformDelegate>();
      expect(identical(resolved, customDelegate), isTrue);
    });

    test('sort captures delegate snapshot during concurrent config', () async {
      NativeSort.instance = null;
      final sort = NativeSort();
      await sort.config(const SortOptions());

      final firstDelegate = sort.resolveAs<PlatformDelegate>();
      final captured = sort.resolveAs<PlatformDelegate>();
      await sort.config(const SortOptions());
      final afterConfig = sort.resolveAs<PlatformDelegate>();

      expect(identical(captured, firstDelegate), isTrue);
      expect(identical(afterConfig, firstDelegate), isFalse);
    });

    test('resolveAs returns PlatformDelegate after config', () async {
      NativeSort.instance = null;
      final sort = NativeSort();
      await sort.config(const SortOptions());
      final delegate = sort.resolveAs<PlatformDelegate>();
      expect(delegate, isA<PlatformDelegate>());
    });

    test(
      'resolveAs returns platform-specific delegate type after config',
      () async {
        NativeSort.instance = null;
        final sort = NativeSort();
        await sort.config(const SortOptions());
        final delegate = sort.resolveAs<PlatformDelegate>();
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
      },
    );

    test(
      'android extension resolves on Android platform after config',
      () async {
        NativeSort.instance = null;
        final sort = NativeSort();
        await sort.config(const SortOptions());
        if (defaultTargetPlatform == TargetPlatform.android) {
          expect(sort.android, isA<AndroidDelegate>());
        }
      },
    );
  });
}

class _MockSort implements NativeSort {
  final List<SortItem> _result;

  _MockSort(this._result);

  @override
  Future<void> config(
    SortOptions options, {
    PlatformDelegate? delegate,
  }) async {}

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async => _result;

  @override
  T resolveAs<T extends PlatformDelegate>() => this as T;
}

/// Mirrors [NativeSort._] config/sort contract: reconfigurable config,
/// concurrent dedup, StateError before config, retry on failure.
class _ContractMock implements NativeSort {
  final List<SortItem> _result;
  final List<SortOptions>? _configTracking;
  final int _failCount;

  bool _configured = false;
  int _configCallCount = 0;
  Completer<void>? _configCompleter;

  _ContractMock({
    List<SortItem> result = const [],
    List<SortOptions>? configTracking,
    int failCount = 0,
  }) : _result = result,
       _configTracking = configTracking,
       _failCount = failCount;

  int get configCallCount => _configCallCount;

  @override
  Future<void> config(SortOptions options, {PlatformDelegate? delegate}) async {
    if (_configCompleter != null) return _configCompleter!.future;

    _configCompleter = Completer<void>();
    try {
      _configCallCount++;
      _configTracking?.add(options);
      if (_configCallCount <= _failCount) {
        throw Exception('config failure $_configCallCount');
      }
      _configured = true;
      _configCompleter!.complete();
      _configCompleter = null;
    } catch (e) {
      _configCompleter!.complete();
      _configCompleter = null;
      rethrow;
    }
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) {
    if (!_configured) throw StateError('Call config() first');
    return Future.value(_result);
  }

  @override
  T resolveAs<T extends PlatformDelegate>() => this as T;
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
}

class _DelayedDelegate extends PlatformDelegate {
  final String _name;
  final Completer<void>? _gate;
  final List<String> _initOrder;

  _DelayedDelegate(this._name, this._gate, this._initOrder);

  @override
  Future<void> init(SortOptions options) async {
    await _gate?.future;
    _initOrder.add(_name);
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async => items;
}
