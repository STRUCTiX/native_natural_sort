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

/// Backend selection for Windows collation.
enum WindowsCollationBackend {
  /// Use the Pigeon MethodChannel path (CompareStringEx, default).
  pigeon,

  /// Use the Dart FFI path (OS-bundled ICU).
  ffi,
}

/// Windows sort — dispatches to Pigeon or FFI based on options.
abstract interface class WindowsSort {
  /// Whether the underlying ICU loader is available (FFI path only).
  bool get isFfiAvailable;

  FutureOr<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    WindowsCollationBackend? backend,
    SortDirection? direction,
  });

  factory WindowsSort({CollationLibraryLoader? loader}) = _WindowsSortImpl;
}

/// Per-platform options for Windows.
abstract interface class SortOptionsWindows {
  /// Collation locale; `null` means system default.
  Locale? get locale;

  /// Which native backend to use (defaults to [WindowsCollationBackend.pigeon]).
  WindowsCollationBackend get backend;

  /// Injectable sort implementation; `null` uses the default.
  WindowsSort? get sort;

  /// Injectable ICU library loader; `null` uses the default.
  CollationLibraryLoader? get loader;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  const factory SortOptionsWindows({
    Locale? locale,
    WindowsCollationBackend backend,
    WindowsSort? sort,
    CollationLibraryLoader? loader,
    SortDirection direction,
  }) = _SortOptionsWindowsImpl;
}

class _WindowsSortImpl implements WindowsSort {
  final _pigeon = _PigeonSort();
  final _FfiSort _ffi;

  _WindowsSortImpl({CollationLibraryLoader? loader})
    : _ffi = _FfiSort(loader: loader);

  @override
  bool get isFfiAvailable => _ffi.isAvailable;

  @override
  FutureOr<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    WindowsCollationBackend? backend,
    SortDirection? direction,
  }) {
    final effectiveBackend = backend ?? WindowsCollationBackend.pigeon;
    return switch (effectiveBackend) {
      WindowsCollationBackend.pigeon => _pigeon.sort(
        items,
        locale: locale,
        direction: direction,
      ),
      WindowsCollationBackend.ffi => _ffi.sort(
        items,
        locale: locale,
        direction: direction,
      ),
    };
  }
}

class _PigeonSort {
  final _host = CollationWindowsHostApi();

  _PigeonSort();

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

class _FfiSort {
  final CollationLibraryLoader _loader;

  _FfiSort({CollationLibraryLoader? loader})
    : _loader = loader ?? WindowsCollationLoader();

  bool get isAvailable => _loader.isAvailable;

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

class _SortOptionsWindowsImpl implements SortOptionsWindows {
  @override
  final Locale? locale;
  @override
  final WindowsCollationBackend backend;
  @override
  final WindowsSort? sort;
  @override
  final CollationLibraryLoader? loader;
  @override
  final SortDirection direction;
  const _SortOptionsWindowsImpl({
    this.locale,
    this.backend = WindowsCollationBackend.pigeon,
    this.sort,
    this.loader,
    this.direction = SortDirection.ascending,
  });
}
