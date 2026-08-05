import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/src/collation.dart';

class _TestCollator implements IcuCollator {
  final CollationCompareFn _compare;
  const _TestCollator(this._compare);

  @override
  int compare(String a, String b) => _compare(a, b);

  @override
  void dispose() {}
}

void main() {
  group('CollatorSort extension', () {
    // Mock compare function: standard Dart string comparison.
    int mockCompare(String a, String b) => a.compareTo(b);

    test('empty items returns empty list', () {
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(
        <String>[],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, isEmpty);
    });

    test('sorts by value ascending', () {
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(
        ['banana', 'apple', 'cherry'],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['apple', 'banana', 'cherry']);
    });

    test('sorts by value descending', () {
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(
        ['banana', 'apple', 'cherry'],
        idOf: (s) => s,
        valueOf: (s) => s,
        descending: true,
      );
      expect(result, ['cherry', 'banana', 'apple']);
    });

    test('ties broken by idOf', () {
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(
        [
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
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(
        [
          const _TestItem('b', '世界'),
          const _TestItem('a', '你好'),
          const _TestItem('c', 'Apple'),
        ],
        idOf: (t) => t.id,
        valueOf: (t) => t.label,
      );
      // Dart default compareTo: 'Apple' < '你好' < '世界' (by Unicode)
      expect(result.map((t) => t.label), ['Apple', '世界', '你好']);
    });

    test('single-element list is unchanged', () {
      final collator = _TestCollator(mockCompare);
      final result = collator.sort(['only'], idOf: (s) => s, valueOf: (s) => s);
      expect(result, ['only']);
    });
  });
}

class _TestItem {
  final String id;
  final String label;
  const _TestItem(this.id, this.label);
}
