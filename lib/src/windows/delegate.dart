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

import '../common.dart';
import '../delegate.dart';
import '../sort.dart';
import 'sort.dart';

class WindowsDelegate extends PlatformDelegate {
  late WindowsSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  CollatorStrength? _defaultStrength;
  CollatorDecomposition? _defaultDecomposition;
  bool? _defaultNumeric;
  bool? _defaultCaseSensitive;
  bool? _defaultDiacriticInsensitive;

  WindowsDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final windows = options.windows;
    _sort = windows?.sort ?? WindowsSort.ffi();
    try {
      await _sort.init();
    } catch (_) {
      final fallback = await windows?.onLoadFailed?.call();
      if (fallback == null) rethrow;
      _sort = fallback;
      await _sort.init();
    }
    _defaultLocale = windows?.locale;
    _defaultDirection = windows?.direction;
    _defaultStrength = windows?.strength;
    _defaultDecomposition = windows?.decomposition;
    _defaultNumeric = windows?.numeric;
    _defaultCaseSensitive = windows?.caseSensitive;
    _defaultDiacriticInsensitive = windows?.diacriticInsensitive;
  }

  @override
  FutureOr<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) => sortWith(
    items,
    direction: direction ?? _defaultDirection,
    locale: locale ?? _defaultLocale,
  );

  /// Sorts [items] with full Windows-specific collator overrides.
  ///
  /// Each named parameter, when non-null, overrides the corresponding
  /// default set via [SortOptionsWindows] during [init].  A `null`
  /// parameter falls back to the init default.
  FutureOr<List<SortItem>> sortWith(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) {
    final platformItems = items
        .map((i) => CollationWindowsItem(id: i.id, value: i.value))
        .toList();
    final result = _sort.sort(
      platformItems,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
      strength: strength ?? _defaultStrength,
      decomposition: decomposition ?? _defaultDecomposition,
      numeric: numeric ?? _defaultNumeric,
      caseSensitive: caseSensitive ?? _defaultCaseSensitive,
      diacriticInsensitive:
          diacriticInsensitive ?? _defaultDiacriticInsensitive,
    );

    List<SortItem> mapBack(List<CollationWindowsItem> list) =>
        list.map((i) => SortItem(id: i.id, value: i.value)).toList();

    if (result is Future<List<CollationWindowsItem>>) {
      return result.then(mapBack);
    }
    return mapBack(result);
  }
}
