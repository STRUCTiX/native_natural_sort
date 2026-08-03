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

/// Android platform sort — Pigeon MethodChannel → ICU Collator.
abstract interface class AndroidSort {
  Future<List<CollationAndroidItem>> sort(
    List<CollationAndroidItem> items, {
    Locale? locale,
    SortDirection? direction,
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

  const factory SortOptionsAndroid({
    Locale? locale,
    AndroidSort? sort,
    SortDirection direction,
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
  }) async {
    final request = CollationAndroidRequest(
      items: items,
      locale: locale?.toLanguageTag(),
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
  const _SortOptionsAndroidImpl({
    this.locale,
    this.sort,
    this.direction = SortDirection.ascending,
  });
}
