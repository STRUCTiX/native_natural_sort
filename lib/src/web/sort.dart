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
import '../sort.dart';

import 'sort_stub.dart' if (dart.library.js_interop) 'sort_web.dart';

/// Web sort — browser-native `Intl.Collator`.
///
/// Uses the ECMAScript Internationalization API
/// ([Intl.Collator]) for locale-aware string collation.
/// The `decomposition` parameter is accepted but ignored —
/// the browser performs unicode normalization automatically.
abstract interface class WebSort {
  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  });

  factory WebSort() = WebSortImpl;
}

/// Per-platform options for web.
///
/// Web uses [Intl.Collator] with configurable options.
/// Defaults match the ICU-based platforms:
/// - [strength]: tertiary (`"case"` sensitivity)
/// - [numeric]: `true` (natural numeric ordering)
/// - [decomposition]: canonical (ignored on web)
abstract interface class SortOptionsWeb {
  /// Collation locale (BCP 47, e.g. `"en-US"`).
  /// `null` uses the browser's default locale.
  Locale? get locale;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  /// Collation strength (defaults to [CollatorStrength.tertiary]).
  CollatorStrength? get strength;

  /// Unicode normalisation mode (defaults to [CollatorDecomposition.canonical]).
  ///
  /// **Web note:** this parameter is accepted for API consistency but
  /// is ignored — the browser always performs automatic unicode
  /// normalization before comparison.
  CollatorDecomposition? get decomposition;

  /// Whether to use natural numeric ordering (defaults to `true`).
  bool? get numeric;

  const factory SortOptionsWeb({
    Locale? locale,
    SortDirection direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) = _SortOptionsWebImpl;
}

class _SortOptionsWebImpl implements SortOptionsWeb {
  @override
  final Locale? locale;
  @override
  final SortDirection direction;
  @override
  final CollatorStrength? strength;
  @override
  final CollatorDecomposition? decomposition;
  @override
  final bool? numeric;

  const _SortOptionsWebImpl({
    this.locale,
    this.direction = SortDirection.ascending,
    this.strength,
    this.decomposition,
    this.numeric,
  });
}
