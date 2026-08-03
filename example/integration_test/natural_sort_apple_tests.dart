part of 'natural_sort_test.dart';

void registerAppleTests() {
  group(
    'Apple (iOS/macOS)',
    () {
      late NativeSort sort;

      setUp(() {
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
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('zh')),
            macOS: SortOptionsMacOS(locale: Locale('zh')),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'lat', value: 'apple'),
          const SortItem(id: 'cjk', value: '中文'),
        ]);
        // Under zh locale, Chinese sorts before Latin.
        expect(result.map((i) => i.id), ['cjk', 'lat']);
      });

      testWidgets('locale: en sorts Latin before Chinese', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('en')),
            macOS: SortOptionsMacOS(locale: Locale('en')),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'lat', value: 'apple'),
          const SortItem(id: 'cjk', value: '中文'),
        ]);
        // Under en locale, Latin sorts before Chinese.
        expect(result.map((i) => i.id), ['lat', 'cjk']);
      });

      testWidgets('numeric: natural numeric ordering (98 < 123)', (
        tester,
      ) async {
        await sort.init(const SortOptions());

        final result = await sort.sort([
          const SortItem(id: 'big', value: 'file123'),
          const SortItem(id: 'small', value: 'file98'),
        ]);
        // Numeric is always on in baseOptions → 98 < 123.
        expect(result.map((i) => i.id), ['small', 'big']);
      });

      testWidgets('caseSensitive: true — case differences matter', (
        tester,
      ) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(caseSensitive: true),
            macOS: SortOptionsMacOS(caseSensitive: true),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'lower', value: 'apple'),
          const SortItem(id: 'upper', value: 'Apple'),
        ]);
        // caseSensitive: true → case matters.
        expect(result.map((i) => i.id), ['lower', 'upper']);
      });

      testWidgets('caseSensitive: false (default) — case-insensitive', (
        tester,
      ) async {
        await sort.init(const SortOptions());

        final result = await sort.sort([
          const SortItem(id: 'a', value: 'apple'),
          const SortItem(id: 'b', value: 'Apple'),
        ]);
        // case-insensitive → forcedOrdering determines order.
        expect(result.map((i) => i.id), ['a', 'b']);
      });

      testWidgets('diacriticInsensitive: true — accent ignored', (
        tester,
      ) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(diacriticInsensitive: true),
            macOS: SortOptionsMacOS(diacriticInsensitive: true),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'a', value: 'café'),
          const SortItem(id: 'b', value: 'cafe'),
        ]);
        // é ≈ e → forcedOrdering breaks tie.
        expect(result.map((i) => i.id), ['b', 'a']);
      });

      testWidgets('diacriticInsensitive: false (default) — e before é', (
        tester,
      ) async {
        await sort.init(const SortOptions());

        final result = await sort.sort([
          const SortItem(id: 'accent', value: 'café'),
          const SortItem(id: 'plain', value: 'cafe'),
        ]);
        // Default: diacritics distinct → 'e' < 'é'.
        expect(result.map((i) => i.id), ['plain', 'accent']);
      });

      testWidgets('caseSensitive + diacriticInsensitive: both true, '
          '"Café" vs "cafe"', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(
              caseSensitive: true,
              diacriticInsensitive: true,
            ),
            macOS: SortOptionsMacOS(
              caseSensitive: true,
              diacriticInsensitive: true,
            ),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'upper_accent', value: 'Café'),
          const SortItem(id: 'lower_plain', value: 'cafe'),
        ]);
        // 'C' ≠ 'c' + 'é' ≈ 'e' → forcedOrdering.
        expect(result.map((i) => i.id), ['lower_plain', 'upper_accent']);
      });

      testWidgets('all options combined: zh locale + descending + '
          'caseSensitive + diacriticInsensitive', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(
              locale: Locale('zh'),
              direction: SortDirection.descending,
              caseSensitive: true,
              diacriticInsensitive: true,
            ),
            macOS: SortOptionsMacOS(
              locale: Locale('zh'),
              direction: SortDirection.descending,
              caseSensitive: true,
              diacriticInsensitive: true,
            ),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'lat', value: 'apple'),
          const SortItem(id: 'cjk', value: '中文'),
        ]);
        // zh locale: Chinese before Latin ascending,
        // so descending → Latin before Chinese.
        expect(result.map((i) => i.id), ['lat', 'cjk']);
      });

      testWidgets('zh locale: Chinese pinyin order (啊<吧<才)', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('zh')),
            macOS: SortOptionsMacOS(locale: Locale('zh')),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'b', value: '吧'),
          const SortItem(id: 'c', value: '才'),
          const SortItem(id: 'a', value: '啊'),
        ]);
        // zh locale → pinyin order: ā(啊) < bā(吧) < cái(才).
        expect(result.map((i) => i.id), ['a', 'b', 'c']);
      });

      testWidgets('en locale: Chinese Unicode order (吧<啊<才)', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('en')),
            macOS: SortOptionsMacOS(locale: Locale('en')),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'b', value: '吧'),
          const SortItem(id: 'c', value: '才'),
          const SortItem(id: 'a', value: '啊'),
        ]);
        // en locale → Unicode code point: U+5427(吧) < U+554A(啊) < U+624D(才).
        expect(result.map((i) => i.id), ['b', 'a', 'c']);
      });

      testWidgets('zh × caseSensitive: Chinese before Latin, '
          'case matters within Latin', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('zh'), caseSensitive: true),
            macOS: SortOptionsMacOS(locale: Locale('zh'), caseSensitive: true),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'upper', value: 'Apple'),
          const SortItem(id: 'lower', value: 'apple'),
          const SortItem(id: 'cjk', value: '啊'),
        ]);
        // zh: 啊 first; then case-sensitive Latin.
        expect(result.map((i) => i.id), ['cjk', 'lower', 'upper']);
      });

      testWidgets('en × caseSensitive: Latin before Chinese, '
          'case matters within Latin', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(locale: Locale('en'), caseSensitive: true),
            macOS: SortOptionsMacOS(locale: Locale('en'), caseSensitive: true),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'upper', value: 'Apple'),
          const SortItem(id: 'lower', value: 'apple'),
          const SortItem(id: 'cjk', value: '啊'),
        ]);
        // en: Latin first (case-sensitive); then 啊.
        expect(result.map((i) => i.id), ['lower', 'upper', 'cjk']);
      });

      testWidgets('zh × diacriticInsensitive: Chinese before Latin, '
          'accent ignored within Latin', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(
              locale: Locale('zh'),
              diacriticInsensitive: true,
            ),
            macOS: SortOptionsMacOS(
              locale: Locale('zh'),
              diacriticInsensitive: true,
            ),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'accent', value: 'café'),
          const SortItem(id: 'plain', value: 'cafe'),
          const SortItem(id: 'cjk', value: '啊'),
        ]);
        // zh: 啊 first; then dia-insensitive Latin.
        expect(result.map((i) => i.id), ['cjk', 'plain', 'accent']);
      });

      testWidgets('en × diacriticInsensitive: Latin before Chinese, '
          'accent ignored within Latin', (tester) async {
        await sort.init(
          const SortOptions(
            ios: SortOptionsIOS(
              locale: Locale('en'),
              diacriticInsensitive: true,
            ),
            macOS: SortOptionsMacOS(
              locale: Locale('en'),
              diacriticInsensitive: true,
            ),
          ),
        );

        final result = await sort.sort([
          const SortItem(id: 'accent', value: 'café'),
          const SortItem(id: 'plain', value: 'cafe'),
          const SortItem(id: 'cjk', value: '啊'),
        ]);
        // en: Latin first (dia-insensitive); then 啊.
        expect(result.map((i) => i.id), ['plain', 'accent', 'cjk']);
      });
    },
    skip:
        defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS,
  );
}
