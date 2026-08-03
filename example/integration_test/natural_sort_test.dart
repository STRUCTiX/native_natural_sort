import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NativeSort sort;

  setUp(() async {
    sort = NativeSort();
    await sort.init(const SortOptions());
  });

  testWidgets('sorts strings in ascending collation order', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'b', value: 'banana'),
      const SortItem(id: 'a', value: 'apple'),
      const SortItem(id: 'c', value: 'cherry'),
    ]);
    expect(result.map((i) => i.id), ['a', 'b', 'c']);
  });

  testWidgets('sorts with numeric awareness (natural sort)', (tester) async {
    final result = await sort.sort([
      const SortItem(id: '10', value: 'file10.txt'),
      const SortItem(id: '2', value: 'file2.txt'),
      const SortItem(id: '1', value: 'file1.txt'),
    ]);
    expect(result.map((i) => i.id), ['1', '2', '10']);
  });

  testWidgets(
    'sorts in descending order',
    (tester) async {
      final result = await sort.sort([
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
        const SortItem(id: 'c', value: 'cherry'),
      ], direction: SortDirection.descending);
      expect(result.map((i) => i.id), ['c', 'b', 'a']);
    },
  );

  testWidgets(
    'sorts case-insensitively with primary strength',
    (tester) async {
      final androidSort = sort.resolveAs<AndroidDelegate>();
      final result = await androidSort.sortWithOptions(
        [
          const SortItem(id: 'B', value: 'Banana'),
          const SortItem(id: 'a', value: 'apple'),
          const SortItem(id: 'C', value: 'cherry'),
        ],
        strength: CollatorStrength.primary,
      );
      expect(result.map((i) => i.id), ['a', 'B', 'C']);
    },
  );

  testWidgets(
    'sorts lexicographically with numeric disabled',
    (tester) async {
      final androidSort = sort.resolveAs<AndroidDelegate>();
      final result = await androidSort.sortWithOptions(
        [
          const SortItem(id: '10', value: 'item10'),
          const SortItem(id: '2', value: 'item2'),
          const SortItem(id: '1', value: 'item1'),
        ],
        numeric: false,
      );
      // Lexicographic: item1 < item10 < item2
      expect(result.map((i) => i.id), ['1', '10', '2']);
    },
  );

  testWidgets('empty list returns empty', (tester) async {
    final result = await sort.sort([]);
    expect(result, isEmpty);
  });

  testWidgets('single item returns itself', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'only', value: 'just one'),
    ]);
    expect(result, [const SortItem(id: 'only', value: 'just one')]);
  });

  testWidgets('ties on value are broken by id', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'id3', value: 'same'),
      const SortItem(id: 'id1', value: 'same'),
      const SortItem(id: 'id2', value: 'same'),
    ]);
    expect(result.map((i) => i.id), ['id1', 'id2', 'id3']);
  });

  testWidgets('init is idempotent', (tester) async {
    await sort.init(const SortOptions());
    // Should not throw or deadlock.
    final result = await sort.sort([const SortItem(id: 'a', value: 'test')]);
    expect(result, [const SortItem(id: 'a', value: 'test')]);
  });
}
