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

import '../sort.dart' show SortDirection;
import 'collation_api.g.dart';

export 'collation_api.g.dart'
    show CollationAndroidHostApi, CollationAndroidItem, CollationAndroidRequest;

/// ICU collation strength level.
///
/// Controls whether case and accent differences affect sort order.
/// Maps to Android [java.text.Collator] strength constants.
enum CollatorStrength {
  /// Base letter differences only (a ≠ b, but a = A = á = À).
  primary,

  /// Base letter + accent differences (a ≠ á, but a = A).
  secondary,

  /// Base letter + accent + case differences (a ≠ A). Default.
  tertiary,

  /// All differences including punctuation.
  identical,
}

/// Unicode normalisation mode for collation.
///
/// Controls whether composed characters are decomposed before comparison.
enum CollatorDecomposition {
  /// No decomposition.
  none,

  /// Canonical decomposition (NFD). Default.
  canonical,

  /// Full decomposition (NFKD) — also decomposes compatibility characters.
  full,
}

/// Android platform sort — Pigeon MethodChannel → ICU Collator.
abstract interface class AndroidSort {
  Future<List<CollationAndroidItem>> sort(
    List<CollationAndroidItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  });

  factory AndroidSort() = _AndroidSortImpl;
}

/// Per-platform options for Android.
abstract interface class SortOptionsAndroid {
  /// ICU collation locale; `null` means system default.
  Locale? get locale;

  /// Injectable sort implementation; `null` uses the default.
  AndroidSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  /// ICU collation strength (defaults to [CollatorStrength.tertiary]).
  CollatorStrength? get strength;

  /// Unicode normalisation mode (defaults to [CollatorDecomposition.canonical]).
  CollatorDecomposition? get decomposition;

  /// Whether to use natural numeric ordering (defaults to `true`).
  bool? get numeric;

  const factory SortOptionsAndroid({
    Locale? locale,
    AndroidSort? sort,
    SortDirection direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) = _SortOptionsAndroidImpl;
}

class _AndroidSortImpl implements AndroidSort {
  final _host = CollationAndroidHostApi();

  _AndroidSortImpl();

  @override
  Future<List<CollationAndroidItem>> sort(
    List<CollationAndroidItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) async {
    final request = CollationAndroidRequest(
      items: items,
      locale: locale?.toLanguageTag(),
      direction: direction?.index,
      strength: strength?.index,
      decomposition: decomposition?.index,
      numeric: numeric,
    );
    return _host.sort(request);
  }
}

class _SortOptionsAndroidImpl implements SortOptionsAndroid {
  @override
  final Locale? locale;
  @override
  final AndroidSort? sort;
  @override
  final SortDirection direction;
  @override
  final CollatorStrength? strength;
  @override
  final CollatorDecomposition? decomposition;
  @override
  final bool? numeric;

  const _SortOptionsAndroidImpl({
    this.locale,
    this.sort,
    this.direction = SortDirection.ascending,
    this.strength,
    this.decomposition,
    this.numeric,
  });
}
