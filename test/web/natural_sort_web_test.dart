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

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Web-only sort', () {
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

    testWidgets('numeric: true (default) — natural (2 < 10)', (tester) async {
      await sort.init(const SortOptions());

      final result = await sort.sort([
        const SortItem(id: '10', value: 'file10.txt'),
        const SortItem(id: '2', value: 'file2.txt'),
        const SortItem(id: '1', value: 'file1.txt'),
      ]);
      expect(result.map((i) => i.id), ['1', '2', '10']);
    });

    testWidgets('numeric: false — lexicographic (1 < 10 < 2)', (tester) async {
      await sort.init(const SortOptions(web: SortOptionsWeb(numeric: false)));

      final result = await sort.sort([
        const SortItem(id: '10', value: 'item10'),
        const SortItem(id: '2', value: 'item2'),
        const SortItem(id: '1', value: 'item1'),
      ]);
      expect(result.map((i) => i.id), ['1', '10', '2']);
    });

    testWidgets('strength: primary — case + accent both ignored', (
      tester,
    ) async {
      await sort.init(
        const SortOptions(
          web: SortOptionsWeb(strength: CollatorStrength.primary),
        ),
      );

      final result = await sort.sort([
        const SortItem(id: 'b', value: 'b'),
        const SortItem(id: 'a', value: 'A'),
        const SortItem(id: 'c', value: 'á'),
      ]);
      expect(result.map((i) => i.id), ['a', 'c', 'b']);
    });

    testWidgets('strength: tertiary — case differs', (tester) async {
      await sort.init(
        const SortOptions(
          web: SortOptionsWeb(strength: CollatorStrength.tertiary),
        ),
      );

      final result = await sort.sort([
        const SortItem(id: 'b', value: 'b'),
        const SortItem(id: 'a', value: 'A'),
      ]);
      expect(result.map((i) => i.id), ['a', 'b']);
    });

    testWidgets('locale: zh sorts Chinese before Latin', (tester) async {
      await sort.init(
        const SortOptions(web: SortOptionsWeb(locale: Locale('zh'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'lat', value: 'apple'),
        const SortItem(id: 'cjk', value: '中文'),
      ]);
      expect(result.map((i) => i.id), ['cjk', 'lat']);
    });

    testWidgets('locale: en sorts Latin before Chinese', (tester) async {
      await sort.init(
        const SortOptions(web: SortOptionsWeb(locale: Locale('en'))),
      );

      final result = await sort.sort([
        const SortItem(id: 'lat', value: 'apple'),
        const SortItem(id: 'cjk', value: '中文'),
      ]);
      expect(result.map((i) => i.id), ['lat', 'cjk']);
    });

    testWidgets('sortWithOptions overrides init strength', (tester) async {
      await sort.init(
        const SortOptions(
          web: SortOptionsWeb(strength: CollatorStrength.primary),
        ),
      );

      final result = await sort.sortWithOptions(
        [
          const SortItem(id: 'b', value: 'B'),
          const SortItem(id: 'a', value: 'a'),
        ],
        options: const SortOptions(
          web: SortOptionsWeb(strength: CollatorStrength.tertiary),
        ),
      );
      expect(result.map((i) => i.id), ['a', 'b']);
    });

    testWidgets('init is idempotent', (tester) async {
      await sort.init(const SortOptions());
      await sort.init(const SortOptions(web: SortOptionsWeb(numeric: false)));
      final result = await sort.sort([const SortItem(id: 'a', value: 'test')]);
      expect(result, [const SortItem(id: 'a', value: 'test')]);
    });

    testWidgets('empty list returns empty', (tester) async {
      await sort.init(const SortOptions());
      final result = await sort.sort([]);
      expect(result, isEmpty);
    });

    testWidgets('single item returns itself', (tester) async {
      await sort.init(const SortOptions());
      final result = await sort.sort([
        const SortItem(id: 'only', value: 'just one'),
      ]);
      expect(result, [const SortItem(id: 'only', value: 'just one')]);
    });

    testWidgets('ties on value are broken by id', (tester) async {
      await sort.init(const SortOptions());
      final result = await sort.sort([
        const SortItem(id: 'id3', value: 'same'),
        const SortItem(id: 'id1', value: 'same'),
        const SortItem(id: 'id2', value: 'same'),
      ]);
      expect(result.map((i) => i.id), ['id1', 'id2', 'id3']);
    });

    testWidgets('Unicode characters are sorted without error', (tester) async {
      await sort.init(const SortOptions());
      final result = await sort.sort([
        const SortItem(id: 'c', value: 'café'),
        const SortItem(id: 'n', value: 'naïve'),
        const SortItem(id: 'r', value: 'résumé'),
      ]);
      expect(result.length, 3);
    });
  }, skip: !kIsWeb);
}
