part of 'natural_sort_test.dart';

void registerBasicSortTests() {
  late NativeSort sort;

  setUp(() async {
    NativeSort.reset();
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

  testWidgets('sorts in descending order', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'a', value: 'apple'),
      const SortItem(id: 'b', value: 'banana'),
      const SortItem(id: 'c', value: 'cherry'),
    ], direction: SortDirection.descending);
    expect(result.map((i) => i.id), ['c', 'b', 'a']);
  });

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
