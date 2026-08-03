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

import 'dart:async';
import 'dart:ui' show Locale;

import '../collation_ffi.dart';
import '../delegate.dart';
import '../sort.dart';
import 'collation_ffi.dart';
import 'sort.dart';

class WindowsDelegate extends PlatformDelegate {
  late final CollationLibraryLoader _loader;
  late final WindowsSort _sort;
  Locale? _defaultLocale;
  WindowsCollationBackend? _defaultBackend;
  SortDirection _defaultDirection = SortDirection.ascending;

  WindowsDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final windows = options.windows;
    _loader = windows?.loader ?? WindowsCollationLoader();
    await _loader.init();
    _sort = windows?.sort ?? WindowsSort(loader: _loader);
    _defaultLocale = windows?.locale;
    _defaultBackend = windows?.backend;
    _defaultDirection = windows?.direction ?? SortDirection.ascending;
  }

  @override
  FutureOr<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) {
    final platformItems = items
        .map((i) => CollationWindowsItem(id: i.id, value: i.value))
        .toList();
    final result = _sort.sort(
      platformItems,
      locale: locale ?? _defaultLocale,
      backend: _defaultBackend,
      direction: direction ?? _defaultDirection,
    );
    if (result is Future<List<CollationWindowsItem>>) {
      return result.then(
        (list) => list.map((i) => SortItem(id: i.id, value: i.value)).toList(),
      );
    }
    return result.map((i) => SortItem(id: i.id, value: i.value)).toList();
  }
}
