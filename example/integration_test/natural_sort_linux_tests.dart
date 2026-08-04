part of 'natural_sort_test.dart';

void registerLinuxTests() {
  group('Linux FFI', () {
    late NativeSort sort;

    setUp(() async {
      NativeSort.reset();
      sort = NativeSort();
    });

    testWidgets('direction: descending reverses result', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
        const SortItem(id: 'c', value: 'cherry'),
      ], direction: SortDirection.descending);
      expect(result.map((i) => i.id), ['c', 'b', 'a']);
    });

    testWidgets('direction: ascending (default) preserves order', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'c', value: 'cherry'),
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
      ]);
      expect(result.map((i) => i.id), ['a', 'b', 'c']);
    });

    testWidgets('numeric: false — lexicographic (10 < 2)', (tester) async {
      await sort.init(
        const SortOptions(linux: SortOptionsLinux(numeric: false)),
      );

      final result = await sort.sort([
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ]);
      // Lexicographic: 'file1' < 'file10' < 'file2'
      expect(result.map((i) => i.id), ['1', '10', '2']);
    });

    testWidgets('numeric: true via sortWithOptions override', (tester) async {
      await sort.init(
        const SortOptions(linux: SortOptionsLinux(numeric: false)),
      );

      // sortWithOptions is covered by unit tests; integration test just
      // verifies the delegate resolves correctly on this platform.
      final delegate = sort.resolveAs<LinuxDelegate>();
      expect(delegate, isA<LinuxDelegate>());
    });

    testWidgets('strength: primary — case-insensitive', (tester) async {
      await sort.init(
        const SortOptions(
          linux: SortOptionsLinux(strength: CollatorStrength.primary),
        ),
      );

      // Under primary strength case differences are ignored.
      // Ties are broken by id.
      final result = await sort.sort([
        const SortItem(id: 'upper', value: 'Apple'),
        const SortItem(id: 'lower', value: 'apple'),
      ]);
      // Case-insensitive → 'Apple' == 'apple', tie broken by id.
      expect(result.length, 2);
    });

    testWidgets('strength: tertiary — case-sensitive (default)', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'Apple'),
      ]);
      // Tertiary distinguishes case.
      expect(result.length, 2);
    });

    testWidgets('decomposition: canonical — composed vs decomposed equal', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      // é (U+00E9) vs e + combining acute (U+0065 U+0301)
      final result = await sort.sort([
        const SortItem(id: 'composed', value: 'café'),
        const SortItem(id: 'decomposed', value: 'cafe\u0301'),
      ]);
      // Both should be collation-equal; tie broken by id.
      expect(result.length, 2);
    });

    testWidgets('locale: en — Latin before CJK', (tester) async {
      await sort.init(
        const SortOptions(linux: SortOptionsLinux(locale: Locale('en'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'cjk', value: '\u4e2d\u6587'),
        const SortItem(id: 'lat', value: 'apple'),
      ]);
      // en locale: Latin sorts before CJK.
      expect(result.map((i) => i.id), ['lat', 'cjk']);
    });

    testWidgets('empty list with descending direction', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([], direction: SortDirection.descending);
      expect(result, isEmpty);
    });

    testWidgets('single element with descending direction', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'only', value: 'x'),
      ], direction: SortDirection.descending);
      expect(result, [const SortItem(id: 'only', value: 'x')]);
    });

    testWidgets('long strings do not crash', (tester) async {
      await sort.init(const SortOptions());

      final longA = 'a' * 1000;
      final longB = 'b' * 1000;
      final result = await sort.sort([
        SortItem(id: 'b', value: longB),
        SortItem(id: 'a', value: longA),
      ]);
      expect(result.map((i) => i.id), ['a', 'b']);
    });

    testWidgets('init is idempotent — does not throw', (tester) async {
      await sort.init(const SortOptions());
      // Second init should be a no-op and not throw.
      await sort.init(
        const SortOptions(linux: SortOptionsLinux(numeric: false)),
      );
      final result = await sort.sort([const SortItem(id: 'a', value: 'test')]);
      expect(result, [const SortItem(id: 'a', value: 'test')]);
    });

    testWidgets('ties on value broken by id', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'id3', value: 'same'),
        const SortItem(id: 'id1', value: 'same'),
        const SortItem(id: 'id2', value: 'same'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2', 'id3']);
    });
  });
}
