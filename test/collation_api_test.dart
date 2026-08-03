import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  });

  group('SortItem', () {
    test('equality', () {
      const a = SortItem(id: 'a', value: 'x');
      const b = SortItem(id: 'a', value: 'x');
      const c = SortItem(id: 'a', value: 'y');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode matches equality', () {
      const a = SortItem(id: 'a', value: 'x');
      const b = SortItem(id: 'a', value: 'x');
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SortOptions', () {
    test('constructs with defaults', () {
      const options = SortOptions();
      expect(options.android, isNull);
      expect(options.linux, isNull);
      expect(options.windows, isNull);
    });

    test('per-platform direction defaults to ascending', () {
      expect(const SortOptionsAndroid().direction, SortDirection.ascending);
      expect(const SortOptionsLinux().direction, SortDirection.ascending);
    });

    test('per-platform options are preserved', () {
      const options = SortOptions(
        android: SortOptionsAndroid(locale: Locale('zh')),
        windows: SortOptionsWindows(
          locale: Locale('en'),
          backend: WindowsCollationBackend.ffi,
        ),
      );
      expect(options.android?.locale, const Locale('zh'));
      expect(options.windows?.locale, const Locale('en'));
      expect(options.windows?.backend, WindowsCollationBackend.ffi);
    });
  });

  group('WindowsCollationBackend', () {
    test('default is pigeon', () {
      expect(
        const SortOptionsWindows().backend,
        WindowsCollationBackend.pigeon,
      );
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
}
