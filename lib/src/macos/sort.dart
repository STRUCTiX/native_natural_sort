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
    show CollationMacOSHostApi, CollationMacOSItem, CollationMacOSRequest;

/// macOS sort — Pigeon MethodChannel → localizedStandardCompare.
abstract interface class MacOSSort {
  Future<List<CollationMacOSItem>> sort(
    List<CollationMacOSItem> items, {
    Locale? locale,
    SortDirection? direction,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  });

  factory MacOSSort() = _MacOSSortImpl;
}

/// Per-platform options for macOS.
///
/// macOS uses `compare(_:options:range:locale:)` with configurable options.
/// Defaults match `localizedStandardCompare`.
abstract interface class SortOptionsMacOS {
  /// Injectable sort implementation; `null` uses the default.
  MacOSSort? get sort;

  /// Locale for collation (e.g. `Locale('en_US')`).
  /// `null` uses the system locale.
  Locale? get locale;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  /// Whether case differences affect sort order.
  /// `null` (default) uses case-insensitive comparison.
  bool? get caseSensitive;

  /// Whether diacritics are ignored.
  /// `null` (default) treats diacritics as distinct.
  bool? get diacriticInsensitive;

  const factory SortOptionsMacOS({
    MacOSSort? sort,
    Locale? locale,
    SortDirection direction,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) = _SortOptionsMacOSImpl;
}

class _MacOSSortImpl implements MacOSSort {
  final _host = CollationMacOSHostApi();

  _MacOSSortImpl();

  @override
  Future<List<CollationMacOSItem>> sort(
    List<CollationMacOSItem> items, {
    Locale? locale,
    SortDirection? direction,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) async {
    final request = CollationMacOSRequest(
      items: items,
      locale: locale?.toLanguageTag(),
      direction: direction?.value,
      caseSensitive: caseSensitive,
      diacriticInsensitive: diacriticInsensitive,
    );
    return _host.sort(request);
  }
}

class _SortOptionsMacOSImpl implements SortOptionsMacOS {
  @override
  final MacOSSort? sort;
  @override
  final Locale? locale;
  @override
  final SortDirection direction;
  @override
  final bool? caseSensitive;
  @override
  final bool? diacriticInsensitive;
  const _SortOptionsMacOSImpl({
    this.sort,
    this.locale,
    this.direction = SortDirection.ascending,
    this.caseSensitive,
    this.diacriticInsensitive,
  });
}
