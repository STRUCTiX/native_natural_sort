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
  });

  factory MacOSSort() = _MacOSSortImpl;
}

/// Per-platform options for macOS.
///
/// macOS uses `localizedStandardCompare` with the system locale —
/// no configurable options are currently exposed.
abstract interface class SortOptionsMacOS {
  /// Injectable sort implementation; `null` uses the default.
  MacOSSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  const factory SortOptionsMacOS({MacOSSort? sort, SortDirection direction}) =
      _SortOptionsMacOSImpl;
}

class _MacOSSortImpl implements MacOSSort {
  final _host = CollationMacOSHostApi();

  _MacOSSortImpl();

  @override
  Future<List<CollationMacOSItem>> sort(
    List<CollationMacOSItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) async {
    final request = CollationMacOSRequest(items: items);
    return _host.sort(request);
  }
}

class _SortOptionsMacOSImpl implements SortOptionsMacOS {
  @override
  final MacOSSort? sort;
  @override
  final SortDirection direction;
  const _SortOptionsMacOSImpl({
    this.sort,
    this.direction = SortDirection.ascending,
  });
}
