part of 'natural_sort_test.dart';

void registerAndroidTests() {
  group('Android-only', () {
    late NativeSort sort;

    setUp(() async {
      NativeSort.reset();
      sort = NativeSort();
    });

    testWidgets('direction: descending', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
        const SortItem(id: 'c', value: 'cherry'),
      ], direction: SortDirection.descending);
      expect(result.map((i) => i.id), ['c', 'b', 'a']);
    });

    testWidgets('locale: zh sorts Chinese before Latin', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('zh'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'lat', value: 'apple'),
        const SortItem(id: 'cjk', value: '中文'),
      ]);
      expect(result.map((i) => i.id), ['cjk', 'lat']);
    });

    testWidgets('locale: en sorts Latin before Chinese', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('en'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'lat', value: 'apple'),
        const SortItem(id: 'cjk', value: '中文'),
      ]);
      expect(result.map((i) => i.id), ['lat', 'cjk']);
    });

    testWidgets('zh locale: Chinese pinyin order (啊<吧<才)', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('zh'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'b', value: '吧'),
        const SortItem(id: 'c', value: '才'),
        const SortItem(id: 'a', value: '啊'),
      ]);
      expect(result.map((i) => i.id), ['a', 'b', 'c']);
    });

    testWidgets('en locale: Chinese Unicode order (吧<啊<才)', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('en'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'b', value: '吧'),
        const SortItem(id: 'c', value: '才'),
        const SortItem(id: 'a', value: '啊'),
      ]);
      expect(result.map((i) => i.id), ['b', 'a', 'c']);
    });

    testWidgets('numeric: true (default) — natural (98 < 123)', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: 'big', value: 'file123'),
        const SortItem(id: 'small', value: 'file98'),
      ]);
      expect(result.map((i) => i.id), ['small', 'big']);
    });

    testWidgets('numeric: false — lexicographic (item1 < item10 < item2)', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.android.sortWith([
        const SortItem(id: '10', value: 'item10'),
        const SortItem(id: '2', value: 'item2'),
        const SortItem(id: '1', value: 'item1'),
      ], numeric: false);
      expect(result.map((i) => i.id), ['1', '10', '2']);
    });

    testWidgets('strength: primary — case + accent both ignored', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'B', value: 'Banana'),
          const SortItem(id: 'a', value: 'apple'),
          const SortItem(id: 'C', value: 'cherry'),
        ],
        locale: const Locale('en'),
        strength: CollatorStrength.primary,
      );
      // en locale → forced ordering (ICU deterministic).
      expect(result.map((i) => i.id), ['a', 'B', 'C']);
    });

    testWidgets('strength: secondary — case ignored, accent matters', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'accent', value: 'café'),
          const SortItem(id: 'plain', value: 'cafe'),
        ],
        locale: const Locale('en'),
        strength: CollatorStrength.secondary,
      );
      // en locale: café ≠ cafe (é ≠ e), case ignored → 'e' < 'é'.
      expect(result.map((i) => i.id), ['plain', 'accent']);
    });

    testWidgets('strength: tertiary (default) — case + accent matter', (
      tester,
    ) async {
      await sort.init(const SortOptions());

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'upper', value: 'Café'),
          const SortItem(id: 'plain', value: 'cafe'),
        ],
        locale: const Locale('en'),
        strength: CollatorStrength.tertiary,
      );
      // en locale: 'C' ≠ 'c' + 'é' ≠ 'e' → both matter.
      expect(result.length, 2);
      expect(result.map((i) => i.id).toSet(), {'upper', 'plain'});
    });

    testWidgets('zh × strength: primary — Chinese before Latin, '
        'case+accent ignored', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('zh'))),
      );

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'upper', value: 'Apple'),
          const SortItem(id: 'lower', value: 'apple'),
          const SortItem(id: 'cjk', value: '啊'),
        ],
        strength: CollatorStrength.primary,
      );
      // zh: 啊 first; Latin case+accent ignored → forced ordering.
      expect(result.map((i) => i.id), ['cjk', 'lower', 'upper']);
    });

    testWidgets('en × strength: secondary — Latin before Chinese, '
        'case ignored', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('en'))),
      );

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'upper', value: 'Apple'),
          const SortItem(id: 'lower', value: 'apple'),
          const SortItem(id: 'cjk', value: '啊'),
        ],
        strength: CollatorStrength.secondary,
      );
      // en: Latin first, case ignored; then 啊.
      expect(result.map((i) => i.id), ['lower', 'upper', 'cjk']);
    });

    testWidgets('zh × numeric: false — Chinese before Latin, '
        'lexicographic Latin', (tester) async {
      await sort.init(
        const SortOptions(android: SortOptionsAndroid(locale: Locale('zh'))),
      );

      final result = await sort.android.sortWith([
        const SortItem(id: 'big', value: 'file123'),
        const SortItem(id: 'small', value: 'file98'),
        const SortItem(id: 'cjk', value: '啊'),
      ], numeric: false);
      // zh: 啊 first; then lexicographic: '1' < '9'.
      expect(result.map((i) => i.id), ['cjk', 'big', 'small']);
    });

    testWidgets('all combined: zh + descending + primary + numeric:false', (
      tester,
    ) async {
      await sort.init(
        const SortOptions(
          android: SortOptionsAndroid(
            locale: Locale('zh'),
            direction: SortDirection.descending,
          ),
        ),
      );

      final result = await sort.android.sortWith(
        [
          const SortItem(id: 'lat', value: 'apple'),
          const SortItem(id: 'cjk', value: '中文'),
        ],
        strength: CollatorStrength.primary,
        numeric: false,
        direction: SortDirection.descending,
      );
      // zh ascending: 中文 before apple;
      // descending flips it: apple before 中文.
      expect(result.map((i) => i.id), ['lat', 'cjk']);
    });
  }, skip: defaultTargetPlatform != TargetPlatform.android);
}
