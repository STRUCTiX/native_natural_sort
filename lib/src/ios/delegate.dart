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

class IOSDelegate extends PlatformDelegate {
  late final IOSSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  bool? _defaultCaseSensitive;
  bool? _defaultDiacriticInsensitive;

  IOSDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final ios = options.ios;
    _sort = ios?.sort ?? IOSSort();
    _defaultLocale = ios?.locale;
    _defaultDirection = ios?.direction;
    _defaultCaseSensitive = ios?.caseSensitive;
    _defaultDiacriticInsensitive = ios?.diacriticInsensitive;
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async {
    final platformItems = items
        .map((i) => CollationIOSItem(id: i.id, value: i.value))
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

  /// Sorts [items] with full iOS-specific collator overrides.
  ///
  /// Each field in [options.ios], when non-null, overrides the default set
  /// via [SortOptionsIOS] during [init].  A `null` field, or [options]
  /// itself being `null`, falls back to the init default.
  @override
  Future<List<SortItem>> sortWithOptions(
    List<SortItem> items, {
    SortOptions? options,
  }) async {
    final ios = options?.ios;
    final platformItems = items
        .map((i) => CollationIOSItem(id: i.id, value: i.value))
        .toList();
    final result = await _sort.sort(
      platformItems,
      locale: ios?.locale ?? _defaultLocale,
      direction: ios?.direction ?? _defaultDirection,
      caseSensitive: ios?.caseSensitive ?? _defaultCaseSensitive,
      diacriticInsensitive:
          ios?.diacriticInsensitive ?? _defaultDiacriticInsensitive,
    );
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }
}
