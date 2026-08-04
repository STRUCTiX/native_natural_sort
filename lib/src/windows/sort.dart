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
import '../sort.dart' show SortDirection;
import 'collation_api.g.dart';
import 'collation_ffi.dart';

export 'collation_api.g.dart'
    show CollationWindowsHostApi, CollationWindowsItem, CollationWindowsRequest;

/// Windows collation interface.
///
/// Two built-in backends are available via named constructors:
/// - [WindowsSort.pigeon] — MethodChannel → CompareStringEx (default).
/// - [WindowsSort.ffi] — Dart FFI → OS-bundled ICU.
abstract interface class WindowsSort {
  /// Whether the backend is ready to use.
  bool get isAvailable;

  /// Initialize the backend (load native libraries if needed).
  Future<void> init();

  /// Sort [items] using platform-native collation.
  FutureOr<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
  });

  /// Pigeon (MethodChannel → CompareStringEx) backend.
  ///
  /// Always available — no native library loading required.
  factory WindowsSort.pigeon() = _WindowsPigeonSort;

  /// FFI (OS-bundled ICU) backend.
  ///
  /// Loads `icu.dll` / `icuin.dll` via [init].  Check [isAvailable] after
  /// initialization to verify the library was found.
  factory WindowsSort.ffi({CollationLibraryLoader? loader}) = _WindowsFfiSort;
}

final class _WindowsPigeonSort implements WindowsSort {
  final CollationWindowsHostApi _host = CollationWindowsHostApi();

  _WindowsPigeonSort();

  @override
  bool get isAvailable => true;

  @override
  Future<void> init() async {}

  @override
  Future<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) async {
    final request = CollationWindowsRequest(
      items: items,
      locale: locale?.toLanguageTag(),
    );
    return _host.sort(request);
  }
}

final class _WindowsFfiSort implements WindowsSort {
  final CollationLibraryLoader _loader;

  _WindowsFfiSort({CollationLibraryLoader? loader})
    : _loader = loader ?? WindowsCollationLoader();

  @override
  bool get isAvailable => _loader.isAvailable;

  @override
  Future<void> init() => _loader.init();

  @override
  List<CollationWindowsItem> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
  }) {
    final collator = _loader.collator(locale?.toLanguageTag(), numeric: true);
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

/// Per-platform options for Windows.
abstract interface class SortOptionsWindows {
  /// Collation locale; `null` means system default.
  Locale? get locale;

  /// Sort implementation (defaults to [WindowsSort.pigeon] when `null`).
  WindowsSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  const factory SortOptionsWindows({
    Locale? locale,
    WindowsSort? sort,
    SortDirection direction,
  }) = _SortOptionsWindowsImpl;
}

class _SortOptionsWindowsImpl implements SortOptionsWindows {
  @override
  final Locale? locale;
  @override
  final WindowsSort? sort;
  @override
  final SortDirection direction;

  const _SortOptionsWindowsImpl({
    this.locale,
    this.sort,
    this.direction = SortDirection.ascending,
  });
}
