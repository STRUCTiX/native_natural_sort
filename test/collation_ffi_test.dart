import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/src/collation_ffi.dart';

void main() {
  group('IcuCollation', () {
    /// Mock compare function: standard Dart string comparison.
    int mockCompare(String a, String b) => a.compareTo(b);

    test('empty items returns empty list', () {
      final collation = IcuCollation.test(mockCompare);
      final result = collation.sort<String>(
        items: [],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, isEmpty);
    });

    test('sorts by value ascending', () {
      final collation = IcuCollation.test(mockCompare);
      final result = collation.sort<String>(
        items: ['banana', 'apple', 'cherry'],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['apple', 'banana', 'cherry']);
    });

    test('sorts by value descending', () {
      final collation = IcuCollation.test(mockCompare);
      final result = collation.sort<String>(
        items: ['banana', 'apple', 'cherry'],
        idOf: (s) => s,
        valueOf: (s) => s,
        descending: true,
      );
      expect(result, ['cherry', 'banana', 'apple']);
    });

    test('ties broken by idOf', () {
      final collation = IcuCollation.test(mockCompare);
      final result = collation.sort<MapEntry<String, String>>(
        items: [
          const MapEntry('id2', 'same'),
          const MapEntry('id1', 'same'),
          const MapEntry('id3', 'same'),
        ],
        idOf: (e) => e.key,
        valueOf: (e) => e.value,
      );
      expect(result.map((e) => e.key), ['id1', 'id2', 'id3']);
    });

    test('handles custom types with idOf/valueOf', () {
      final collation = IcuCollation.test(mockCompare);
      final items = [
        const _TestItem('b', '世界'),
        const _TestItem('a', '你好'),
        const _TestItem('c', 'Apple'),
      ];
      final result = collation.sort<_TestItem>(
        items: items,
        idOf: (t) => t.id,
        valueOf: (t) => t.label,
      );
      // Dart default compareTo: 'Apple' < '你好' < '世界' (by Unicode)
      expect(result.map((t) => t.label), ['Apple', '世界', '你好']);
    });

    test('dispose does not throw for test instance', () {
      final collation = IcuCollation.test(mockCompare);
      expect(collation.dispose, returnsNormally);
    });
  });
}

class _TestItem {
  final String id;
  final String label;
  const _TestItem(this.id, this.label);
}
