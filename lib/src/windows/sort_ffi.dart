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

import 'dart:async';
import 'dart:ui' show Locale;

import '../collation.dart';
import '../common.dart';
import '../sort.dart' show SortDirection;
import 'collation_ffi.dart';
import 'sort.dart';

final class WindowsFfiSort implements WindowsSort {
  final CollationLibraryLoader _loader;

  WindowsFfiSort({CollationLibraryLoader? loader})
    : _loader = loader ?? WindowsCollationLoader();

  @override
  Future<void> init() => _loader.init();

  @override
  List<CollationWindowsItem> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) {
    final collator = _loader.collator(
      locale?.toLanguageTag(),
      numeric: numeric ?? true,
      strength: strength?.value,
      decomposition: decomposition?.value,
    );
    try {
      return collator.sort(
        items,
        idOf: (i) => i.id,
        valueOf: (i) => i.value,
        descending: direction == SortDirection.descending,
      );
    } finally {
      collator.dispose();
    }
  }
}
