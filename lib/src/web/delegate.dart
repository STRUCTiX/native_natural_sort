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

class WebDelegate extends PlatformDelegate {
  late final WebSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  CollatorStrength? _defaultStrength;
  CollatorDecomposition? _defaultDecomposition;
  bool? _defaultNumeric;

  WebDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final web = options.web;
    _sort = WebSort();
    _defaultLocale = web?.locale;
    _defaultDirection = web?.direction;
    _defaultStrength = web?.strength;
    _defaultDecomposition = web?.decomposition;
    _defaultNumeric = web?.numeric;
  }

  @override
  List<SortItem> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) => sortWith(
    items,
    direction: direction ?? _defaultDirection,
    locale: locale ?? _defaultLocale,
  );

  /// Sorts [items] with full web-specific collator overrides.
  ///
  /// Each named parameter, when non-null, overrides the corresponding
  /// default set via [SortOptionsWeb] during [init].  A `null`
  /// parameter falls back to the init default.
  List<SortItem> sortWith(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) {
    return _sort.sort(
      items,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
      strength: strength ?? _defaultStrength,
      decomposition: decomposition ?? _defaultDecomposition,
      numeric: numeric ?? _defaultNumeric,
    );
  }
}
