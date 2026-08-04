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

import '../android/sort.dart' show CollatorDecomposition, CollatorStrength;
import '../collation_ffi.dart';
import '../delegate.dart';
import '../sort.dart';
import 'collation_ffi.dart';
import 'sort.dart';

class LinuxDelegate extends PlatformDelegate {
  late final CollationLibraryLoader _loader;
  late final LinuxSort _sort;
  Locale? _defaultLocale;
  SortDirection? _defaultDirection;
  CollatorStrength? _defaultStrength;
  CollatorDecomposition? _defaultDecomposition;
  bool? _defaultNumeric;

  LinuxDelegate();

  @override
  Future<void> init(SortOptions options) async {
    final linux = options.linux;
    _loader = linux?.loader ?? LinuxCollationLoader();
    await _loader.init();
    _sort = linux?.sort ?? LinuxSort(loader: _loader);
    _defaultLocale = linux?.locale;
    _defaultDirection = linux?.direction;
    _defaultStrength = linux?.strength;
    _defaultDecomposition = linux?.decomposition;
    _defaultNumeric = linux?.numeric;
  }

  @override
  List<SortItem> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) {
    return _sort.sort(
      items,
      locale: locale ?? _defaultLocale,
      direction: direction ?? _defaultDirection,
      strength: _defaultStrength,
      decomposition: _defaultDecomposition,
      numeric: _defaultNumeric,
    );
  }

  /// Sorts [items] with full Linux-specific collator overrides.
  ///
  /// Each field in [options.linux], when non-null, overrides the default
  /// set via [SortOptionsLinux] during [init].  A `null` field, or
  /// [options] itself being `null`, falls back to the init default.
  @override
  List<SortItem> sortWithOptions(List<SortItem> items, {SortOptions? options}) {
    final linux = options?.linux;
    return _sort.sort(
      items,
      locale: linux?.locale ?? _defaultLocale,
      direction: linux?.direction ?? _defaultDirection,
      strength: linux?.strength ?? _defaultStrength,
      decomposition: linux?.decomposition ?? _defaultDecomposition,
      numeric: linux?.numeric ?? _defaultNumeric,
    );
  }
}
