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

import 'dart:js_interop';
import 'dart:ui' show Locale;

import '../common.dart';
import '../sort.dart';
import 'sort.dart';

@JS('Intl.Collator')
extension type JSCollator._(JSObject _) implements JSObject {
  external JSCollator(String? locales, JSCollatorOptions? options);
  external int compare(String a, String b);
}

extension type JSCollatorOptions._(JSObject _) implements JSObject {
  external JSCollatorOptions({
    String? sensitivity,
    bool? numeric,
    String? caseFirst,
    bool? ignorePunctuation,
  });
}

/// Maps [CollatorStrength] to `Intl.Collator` sensitivity.
String _mapSensitivity(CollatorStrength? strength) => switch (strength) {
  CollatorStrength.primary => 'base',
  CollatorStrength.secondary => 'accent',
  CollatorStrength.tertiary => 'case',
  CollatorStrength.identical => 'variant',
  _ => 'case', // default: tertiary
};

class WebSortImpl implements WebSort {
  WebSortImpl();

  @override
  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) {
    if (items.isEmpty) return [];

    final collator = JSCollator(
      locale?.toLanguageTag() ?? 'und',
      JSCollatorOptions(
        sensitivity: _mapSensitivity(strength),
        numeric: numeric ?? true,
      ),
    );
    try {
      if (items.length == 1) return items;

      // Stable sort: sort indices then reorder.
      final indices = List<int>.generate(items.length, (i) => i);
      indices.sort((a, b) {
        final cmp = collator.compare(items[a].value, items[b].value);
        if (cmp != 0) return direction == SortDirection.descending ? -cmp : cmp;
        // Tie-break by id.
        final idCmp = items[a].id.compareTo(items[b].id);
        return direction == SortDirection.descending ? -idCmp : idCmp;
      });
      return indices.map((i) => items[i]).toList();
    } finally {
      // JS GC will collect; no explicit dispose needed.
    }
  }
}
