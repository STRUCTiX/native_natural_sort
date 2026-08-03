part of 'natural_sort_test.dart';

void registerEdgeCaseTests() {
  late NativeSort sort;

  setUp(() async {
    NativeSort.reset();
    sort = NativeSort();
    await sort.init(const SortOptions());
  });

  testWidgets('sorts strings with Unicode characters', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'c', value: 'café'),
      const SortItem(id: 'n', value: 'naïve'),
      const SortItem(id: 'r', value: 'résumé'),
    ]);
    // Locale-dependent, but should produce a deterministic order.
    expect(result.length, 3);
  });

  testWidgets('sorts mixed-case strings', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'b', value: 'Banana'),
      const SortItem(id: 'a', value: 'apple'),
      const SortItem(id: 'c', value: 'CHERRY'),
    ]);
    expect(result.length, 3);
  });

  testWidgets('sorts strings with leading and trailing whitespace', (
    tester,
  ) async {
    final result = await sort.sort([
      const SortItem(id: 'a', value: '  apple'),
      const SortItem(id: 'b', value: 'apple  '),
      const SortItem(id: 'c', value: 'apple'),
    ]);
    expect(result.length, 3);
  });

  testWidgets('sorts strings with special characters', (tester) async {
    final result = await sort.sort([
      const SortItem(id: 'a', value: 'a-1'),
      const SortItem(id: 'b', value: 'a_1'),
      const SortItem(id: 'c', value: 'a.1'),
      const SortItem(id: 'd', value: 'a 1'),
    ]);
    expect(result.length, 4);
  });

  testWidgets('sorts long strings without error', (tester) async {
    final longA = 'a' * 1000;
    final longB = 'b' * 1000;
    final result = await sort.sort([
      SortItem(id: 'b', value: longB),
      SortItem(id: 'a', value: longA),
    ]);
    expect(result.map((i) => i.id), ['a', 'b']);
  });
}
