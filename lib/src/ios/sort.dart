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
    show CollationIOSHostApi, CollationIOSItem, CollationIOSRequest;

/// iOS sort — Pigeon MethodChannel → localizedStandardCompare.
abstract interface class IOSSort {
  Future<List<CollationIOSItem>> sort(
    List<CollationIOSItem> items, {
    Locale? locale,
    SortDirection? direction,
  });

  factory IOSSort() = _IOSSortImpl;
}

/// Per-platform options for iOS.
///
/// iOS uses `localizedStandardCompare` with the system locale —
/// no configurable options are currently exposed.
abstract interface class SortOptionsIOS {
  /// Injectable sort implementation; `null` uses the default.
  IOSSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  const factory SortOptionsIOS({IOSSort? sort, SortDirection direction}) =
      _SortOptionsIOSImpl;
}

class _IOSSortImpl implements IOSSort {
  final _host = CollationIOSHostApi();

  _IOSSortImpl();

  @override
  Future<List<CollationIOSItem>> sort(
    List<CollationIOSItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) async {
    final request = CollationIOSRequest(items: items);
    return _host.sort(request);
  }
}

class _SortOptionsIOSImpl implements SortOptionsIOS {
  @override
  final IOSSort? sort;
  @override
  final SortDirection direction;
  const _SortOptionsIOSImpl({
    this.sort,
    this.direction = SortDirection.ascending,
  });
}
