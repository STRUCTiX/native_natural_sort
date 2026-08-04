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

/// Windows FFI (OS-bundled ICU) integration tests.
///
/// Uses [SortOptionsWindows.ffi] to load icu.dll / icuin.dll and exercise
/// the full ICU collation pipeline on Windows.
void registerWindowsFfiTests() {
  group('Windows FFI (ICU)', () {
    late NativeSort sort;

    setUp(() async {
      NativeSort.reset();
      sort = NativeSort();
    });

    testWidgets('direction: descending reverses result', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

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
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final result = await sort.sort([
        const SortItem(id: 'c', value: 'cherry'),
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
      ]);
      expect(result.map((i) => i.id), ['a', 'b', 'c']);
    });

    testWidgets('numeric: false — lexicographic (10 < 2)', (tester) async {
      await sort.init(
        SortOptions(windows: SortOptionsWindows.ffi(numeric: false)),
      );

      final result = await sort.sort([
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ]);
      // Lexicographic: 'file1' < 'file10' < 'file2'
      expect(result.map((i) => i.id), ['1', '10', '2']);
    });

    testWidgets('numeric: true — natural sort (default)', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final result = await sort.sort([
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ]);
      // Natural: 'file1' < 'file2' < 'file10'
      expect(result.map((i) => i.id), ['1', '2', '10']);
    });

    testWidgets('strength: primary — case-insensitive', (tester) async {
      await sort.init(
        SortOptions(
          windows: SortOptionsWindows.ffi(strength: CollatorStrength.primary),
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
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

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
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

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
        SortOptions(
          windows: SortOptionsWindows.ffi(locale: const Locale('en')),
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
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final result = await sort.sort([], direction: SortDirection.descending);
      expect(result, isEmpty);
    });

    testWidgets('single element with descending direction', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final result = await sort.sort([
        const SortItem(id: 'only', value: 'x'),
      ], direction: SortDirection.descending);
      expect(result, [const SortItem(id: 'only', value: 'x')]);
    });

    testWidgets('long strings do not crash', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final longA = 'a' * 1000;
      final longB = 'b' * 1000;
      final result = await sort.sort([
        SortItem(id: 'b', value: longB),
        SortItem(id: 'a', value: longA),
      ]);
      expect(result.map((i) => i.id), ['a', 'b']);
    });

    testWidgets('init is idempotent — does not throw', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));
      // Second init should be a no-op and not throw.
      await sort.init(
        SortOptions(windows: SortOptionsWindows.ffi(numeric: false)),
      );
      final result = await sort.sort([const SortItem(id: 'a', value: 'test')]);
      expect(result, [const SortItem(id: 'a', value: 'test')]);
    });

    testWidgets('ties on value broken by id', (tester) async {
      await sort.init(SortOptions(windows: SortOptionsWindows.ffi()));

      final result = await sort.sort([
        const SortItem(id: 'id3', value: 'same'),
        const SortItem(id: 'id1', value: 'same'),
        const SortItem(id: 'id2', value: 'same'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2', 'id3']);
    });

    testWidgets('sortWithOptions overrides numeric per-call', (tester) async {
      await sort.init(
        SortOptions(windows: SortOptionsWindows.ffi(numeric: true)),
      );

      // Override numeric to false at call time.
      final result = await sort.sortWithOptions([
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ], options: SortOptions(windows: SortOptionsWindows(numeric: false)));
      // Lexicographic: 'file1' < 'file10' < 'file2'
      expect(result.map((i) => i.id), ['1', '10', '2']);
    });
  });
}
