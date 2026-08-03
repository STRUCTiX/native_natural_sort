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

class AndroidDelegate extends PlatformDelegate {
  late final AndroidSort _sort;
  Locale? _defaultLocale;
  SortDirection _defaultDirection = SortDirection.ascending;

  AndroidDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final android = options.android;
    _sort = android?.sort ?? AndroidSort();
    _defaultLocale = android?.locale;
    _defaultDirection = android?.direction ?? SortDirection.ascending;
  }

  @override
  Future<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) async {
    final platformItems = items
        .map((i) => CollationAndroidItem(id: i.id, value: i.value))
        .toList();
    final result = await _sort.sort(
      platformItems,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
    );
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }
}
