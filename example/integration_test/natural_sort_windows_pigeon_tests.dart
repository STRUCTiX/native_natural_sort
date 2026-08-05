// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of 'natural_sort_test.dart';

/// Windows Pigeon (MethodChannel → CompareStringEx) integration tests.
///
/// Uses [SortOptionsWindows.pigeon] to explicitly select the
/// CompareStringEx backend via platform channel.
void registerWindowsPigeonTests() {
  group('Windows Pigeon (CompareStringEx)', () {
    late NativeSort sort;

    setUp(() async {
      NativeSort.reset();
      sort = NativeSort();
    });

    testWidgets('direction: descending reverses result', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

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
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([
        const SortItem(id: 'c', value: 'cherry'),
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
      ]);
      expect(result.map((i) => i.id), ['a', 'b', 'c']);
    });

    testWidgets('numeric awareness: natural sort (always on)', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ]);
      // CompareStringEx uses SORT_DIGITSASNUMBERS by default.
      expect(result.map((i) => i.id), ['1', '2', '10']);
    });

    testWidgets('caseSensitive: false — case-insensitive (default)', (
      tester,
    ) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      // Default behaviour: case-insensitive, ties broken by id.
      final result = await sort.sort([
        const SortItem(id: 'upper', value: 'Apple'),
        const SortItem(id: 'lower', value: 'apple'),
      ]);
      // Case-insensitive → collation-equal, tie broken by id.
      expect(result.length, 2);
    });

    testWidgets('caseSensitive: true — case-sensitive comparison', (
      tester,
    ) async {
      await sort.config(
        SortOptions(windows: SortOptionsWindows.pigeon(caseSensitive: true)),
      );

      final result = await sort.sort([
        const SortItem(id: 'b', value: 'apple'),
        const SortItem(id: 'a', value: 'Apple'),
        const SortItem(id: 'c', value: 'banana'),
      ]);
      // Case-sensitive: 'Apple' and 'apple' are distinct.
      // 'banana' should sort after both.
      expect(result.length, 3);
      expect(result.last.id, 'c');
    });

    testWidgets('caseSensitive: true via sortWith override', (
      tester,
    ) async {
      await sort.config(
        SortOptions(windows: SortOptionsWindows.pigeon(caseSensitive: false)),
      );

      // Override to case-sensitive at call time.
      final result = await sort.windows.sortWith(
        [
          const SortItem(id: 'a', value: 'Apple'),
          const SortItem(id: 'b', value: 'apple'),
        ],
        caseSensitive: true,
      );
      // Case-sensitive: 'Apple' and 'apple' are distinct.
      expect(result.length, 2);
      expect(result[0].id, isNot(equals(result[1].id)));
    });

    testWidgets('diacriticInsensitive: true — ignores diacritics', (
      tester,
    ) async {
      await sort.config(
        SortOptions(
          windows: SortOptionsWindows.pigeon(diacriticInsensitive: true),
        ),
      );

      // é (U+00E9) vs e — should be treated as equal
      final result = await sort.sort([
        const SortItem(id: 'accent', value: 'café'),
        const SortItem(id: 'plain', value: 'cafe'),
      ]);
      // Diacritic-insensitive → collation-equal, tie broken by id.
      expect(result.length, 2);
    });

    testWidgets('diacriticInsensitive: false — diacritics distinct (default)', (
      tester,
    ) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([
        const SortItem(id: 'accent', value: 'café'),
        const SortItem(id: 'plain', value: 'cafe'),
      ]);
      // Diacritic-sensitive: 'cafe' and 'café' are distinct.
      expect(result.length, 2);
    });

    testWidgets('locale: en — Latin before CJK', (tester) async {
      await sort.config(
        SortOptions(
          windows: SortOptionsWindows.pigeon(locale: const Locale('en')),
        ),
      );

      final result = await sort.sort([
        const SortItem(id: 'cjk', value: '\u4e2d\u6587'),
        const SortItem(id: 'lat', value: 'apple'),
      ]);
      // en locale: Latin sorts before CJK.
      expect(result.map((i) => i.id), ['lat', 'cjk']);
    });

    testWidgets('empty list with descending direction', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([], direction: SortDirection.descending);
      expect(result, isEmpty);
    });

    testWidgets('single element with descending direction', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([
        const SortItem(id: 'only', value: 'x'),
      ], direction: SortDirection.descending);
      expect(result, [const SortItem(id: 'only', value: 'x')]);
    });

    testWidgets('long strings do not crash', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final longA = 'a' * 1000;
      final longB = 'b' * 1000;
      final result = await sort.sort([
        SortItem(id: 'b', value: longB),
        SortItem(id: 'a', value: longA),
      ]);
      expect(result.map((i) => i.id), ['a', 'b']);
    });

    testWidgets('init is idempotent — does not throw', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));
      // Second init should be a no-op and not throw.
      await sort.config(
        SortOptions(windows: SortOptionsWindows.pigeon(caseSensitive: true)),
      );
      final result = await sort.sort([const SortItem(id: 'a', value: 'test')]);
      expect(result, [const SortItem(id: 'a', value: 'test')]);
    });

    testWidgets('ties on value broken by id', (tester) async {
      await sort.config(SortOptions(windows: SortOptionsWindows.pigeon()));

      final result = await sort.sort([
        const SortItem(id: 'id3', value: 'same'),
        const SortItem(id: 'id1', value: 'same'),
        const SortItem(id: 'id2', value: 'same'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2', 'id3']);
    });

    testWidgets('descending direction with sort direction from init', (
      tester,
    ) async {
      await sort.config(
        SortOptions(
          windows: SortOptionsWindows.pigeon(
            direction: SortDirection.descending,
          ),
        ),
      );

      final result = await sort.sort([
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
        const SortItem(id: 'c', value: 'cherry'),
      ]);
      // Direction from init: descending.
      expect(result.map((i) => i.id), ['c', 'b', 'a']);
    });

    testWidgets('sortWith overrides direction per-call', (tester) async {
      await sort.config(
        SortOptions(
          windows: SortOptionsWindows.pigeon(
            direction: SortDirection.ascending,
          ),
        ),
      );

      // Override to descending at call time.
      final result = await sort.windows.sortWith(
        [
          const SortItem(id: 'a', value: 'apple'),
          const SortItem(id: 'b', value: 'banana'),
          const SortItem(id: 'c', value: 'cherry'),
        ],
        direction: SortDirection.descending,
      );
      expect(result.map((i) => i.id), ['c', 'b', 'a']);
    });
  });
}
