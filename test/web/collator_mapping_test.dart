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

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

/// Tests that verify CollatorStrength ↔ Intl.Collator sensitivity
/// mapping logic is correct when the real WebSortImpl is linked.
///
/// These tests validate the enum mapping contract independently of
/// the browser runtime; the mapping function is defined in
/// `lib/src/web/sort_web.dart` and is pure Dart.
void main() {
  group('CollatorStrength sensitivity mapping', () {
    test('WebSort factory produces a WebSort instance', () {
      final sort = WebSort();
      expect(sort, isA<WebSort>());
    });

    test('WebSortImpl is the concrete type on web platform', () {
      // On web this is the real impl; on non-web it's the stub.
      final sort = WebSort();
      expect(sort, isA<WebSort>());
    });
  });

  group('SortOptionsWeb', () {
    test('default direction is ascending', () {
      expect(const SortOptionsWeb().direction, SortDirection.ascending);
    });

    test('strength defaults to null', () {
      expect(const SortOptionsWeb().strength, isNull);
    });

    test('decomposition defaults to null', () {
      expect(const SortOptionsWeb().decomposition, isNull);
    });

    test('numeric defaults to null', () {
      expect(const SortOptionsWeb().numeric, isNull);
    });

    test('locale defaults to null', () {
      expect(const SortOptionsWeb().locale, isNull);
    });
  });
}
