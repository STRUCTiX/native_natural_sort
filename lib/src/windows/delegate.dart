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
  late final WindowsSort _sort;
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
    await _sort.init();
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
  }) => _doSort(
    items,
    locale: locale,
    direction: direction,
    strength: _defaultStrength,
    decomposition: _defaultDecomposition,
    numeric: _defaultNumeric,
    caseSensitive: _defaultCaseSensitive,
    diacriticInsensitive: _defaultDiacriticInsensitive,
  );

  @override
  FutureOr<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) {
    final windows = options?.windows;
    return _doSort(
      items,
      locale: windows?.locale ?? _defaultLocale,
      direction: windows?.direction ?? _defaultDirection,
      strength: windows?.strength ?? _defaultStrength,
      decomposition: windows?.decomposition ?? _defaultDecomposition,
      numeric: windows?.numeric ?? _defaultNumeric,
      caseSensitive: windows?.caseSensitive ?? _defaultCaseSensitive,
      diacriticInsensitive:
          windows?.diacriticInsensitive ?? _defaultDiacriticInsensitive,
    );
  }

  FutureOr<List<SortItem>> _doSort(
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
      strength: strength,
      decomposition: decomposition,
      numeric: numeric,
      caseSensitive: caseSensitive,
      diacriticInsensitive: diacriticInsensitive,
    );

    List<SortItem> mapBack(List<CollationWindowsItem> list) =>
        list.map((i) => SortItem(id: i.id, value: i.value)).toList();

    if (result is Future<List<CollationWindowsItem>>) {
      return result.then(mapBack);
    }
    return mapBack(result);
  }
}
