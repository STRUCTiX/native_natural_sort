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

import '../common.dart';
import '../delegate.dart';
import '../sort.dart';
import 'sort.dart';

class AndroidDelegate extends PlatformDelegate {
  late final AndroidSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  CollatorStrength? _defaultStrength;
  CollatorDecomposition? _defaultDecomposition;
  bool? _defaultNumeric;

  AndroidDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final android = options.android;
    _sort = android?.sort ?? AndroidSort();
    _defaultLocale = android?.locale;
    _defaultDirection = android?.direction;
    _defaultStrength = android?.strength;
    _defaultDecomposition = android?.decomposition;
    _defaultNumeric = android?.numeric;
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async => sortWith(
    items,
    direction: direction ?? _defaultDirection,
    locale: locale ?? _defaultLocale,
  );

  /// Sorts [items] with full Android-specific collator overrides.
  ///
  /// Each named parameter, when non-null, overrides the corresponding
  /// default set via [SortOptionsAndroid] during [init].  A `null`
  /// parameter falls back to the init default.
  Future<List<SortItem>> sortWith(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) async {
    final platformItems = items
        .map((i) => CollationAndroidItem(id: i.id, value: i.value))
        .toList();
    final result = await _sort.sort(
      platformItems,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
      strength: strength ?? _defaultStrength,
      decomposition: decomposition ?? _defaultDecomposition,
      numeric: numeric ?? _defaultNumeric,
    );
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }
}
