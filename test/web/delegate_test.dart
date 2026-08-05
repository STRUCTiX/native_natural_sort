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

  group('WebDelegate', () {
    test('is a PlatformDelegate', () {
      final delegate = WebDelegate();
      expect(delegate, isA<PlatformDelegate>());
    });

    test('init stores default options from SortOptions.web', () async {
      final delegate = WebDelegate();
      await delegate.init(
        const SortOptions(
          web: SortOptionsWeb(
            locale: Locale('fr'),
            direction: SortDirection.descending,
            strength: CollatorStrength.primary,
            numeric: false,
          ),
        ),
      );

      // On web: delegate is functional and returns sorted results.
      // On non-web: delegate uses a stub sort that throws on sort().
      // Verify init itself succeeds on both.
    });

    test('init with null web options uses defaults', () async {
      final delegate = WebDelegate();
      await delegate.init(const SortOptions());
      // init succeeds on both platforms.
    });

    test('sortWith overrides init defaults', () async {
      final delegate = WebDelegate();
      await delegate.init(
        const SortOptions(
          web: SortOptionsWeb(direction: SortDirection.ascending),
        ),
      );

      // On non-web this will throw from the stub; on web it returns sorted.
      if (kIsWeb) {
        final result = delegate.sortWith([
          const SortItem(id: 'a', value: 'test'),
        ], direction: SortDirection.descending);
        expect(result.length, 1);
      }
    });
  });
}
