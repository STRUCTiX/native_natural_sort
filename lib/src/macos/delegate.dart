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

import '../delegate.dart';
import '../sort.dart';
import 'sort.dart';

class MacOSDelegate extends PlatformDelegate {
  late final MacOSSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  bool? _defaultCaseSensitive;
  bool? _defaultDiacriticInsensitive;

  MacOSDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final macOS = options.macOS;
    _sort = macOS?.sort ?? MacOSSort();
    _defaultLocale = macOS?.locale;
    _defaultDirection = macOS?.direction;
    _defaultCaseSensitive = macOS?.caseSensitive;
    _defaultDiacriticInsensitive = macOS?.diacriticInsensitive;
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async {
    final platformItems = items
        .map((i) => CollationMacOSItem(id: i.id, value: i.value))
        .toList();
    final result = await _sort.sort(
      platformItems,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
      caseSensitive: _defaultCaseSensitive,
      diacriticInsensitive: _defaultDiacriticInsensitive,
    );
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }

  /// Sorts [items] with full macOS-specific collator overrides.
  ///
  /// Each field in [options.macOS], when non-null, overrides the default
  /// set via [SortOptionsMacOS] during [init].  A `null` field, or
  /// [options] itself being `null`, falls back to the init default.
  @override
  Future<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) async {
    final macOS = options?.macOS;
    final platformItems = items
        .map((i) => CollationMacOSItem(id: i.id, value: i.value))
        .toList();
    final result = await _sort.sort(
      platformItems,
      locale: macOS?.locale ?? _defaultLocale,
      direction: macOS?.direction ?? _defaultDirection,
      caseSensitive: macOS?.caseSensitive ?? _defaultCaseSensitive,
      diacriticInsensitive:
          macOS?.diacriticInsensitive ?? _defaultDiacriticInsensitive,
    );
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }
}
