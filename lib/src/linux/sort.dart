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

import '../collation_cache.dart';
import '../collation_ffi.dart';
import '../sort.dart';
import 'collation_ffi.dart';

/// Linux sort — Dart FFI → system libicui18n.
abstract interface class LinuxSort {
  /// Whether the underlying ICU loader is available.
  bool get isAvailable;

  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
  });

  factory LinuxSort({CollationLibraryLoader? loader}) = _LinuxSortImpl;
}

/// Per-platform options for Linux.
abstract interface class SortOptionsLinux {
  /// ICU collation locale; `null` means system default.
  Locale? get locale;

  /// Injectable sort implementation; `null` uses the default.
  LinuxSort? get sort;

  /// Injectable ICU library loader; `null` uses the default.
  CollationLibraryLoader? get loader;

  /// Injectable cache for resolved library path; `null` uses in-memory.
  CollationCache? get cache;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  const factory SortOptionsLinux({
    Locale? locale,
    LinuxSort? sort,
    CollationLibraryLoader? loader,
    CollationCache? cache,
    SortDirection direction,
  }) = _SortOptionsLinuxImpl;
}

class _LinuxSortImpl implements LinuxSort {
  final CollationLibraryLoader _loader;

  _LinuxSortImpl({CollationLibraryLoader? loader})
    : _loader = loader ?? LinuxCollationLoader();

  @override
  bool get isAvailable => _loader.isAvailable;

  @override
  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) {
    final collator = _loader.collator(locale?.toLanguageTag());
    try {
      return collator.sort(
        items,
        idOf: (i) => i.id,
        valueOf: (i) => i.value,
        descending: direction == SortDirection.descending,
      );
    } finally {
      collator.dispose();
    }
  }
}

class _SortOptionsLinuxImpl implements SortOptionsLinux {
  @override
  final Locale? locale;
  @override
  final LinuxSort? sort;
  @override
  final CollationLibraryLoader? loader;
  @override
  final CollationCache? cache;
  @override
  final SortDirection direction;
  const _SortOptionsLinuxImpl({
    this.locale,
    this.sort,
    this.loader,
    this.cache,
    this.direction = SortDirection.ascending,
  });
}
