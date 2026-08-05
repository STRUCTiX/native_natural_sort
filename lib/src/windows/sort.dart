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

import '../collation.dart';
import '../common.dart';
import '../sort.dart' show SortDirection;
import 'collation_api.g.dart';

import 'sort_stub.dart' if (dart.library.io) 'sort_ffi.dart';

export 'collation_api.g.dart' show CollationWindowsItem;

/// Windows collation interface.
///
/// Two built-in backends are available via named constructors:
/// - [WindowsSort.pigeon] — MethodChannel → CompareStringEx (default).
/// - [WindowsSort.ffi] — Dart FFI → OS-bundled ICU.
abstract interface class WindowsSort {
  /// Initialize the backend (load native libraries if needed).
  ///
  /// Must be called before [sort].  Safe to call multiple times —
  /// only the first invocation performs work.
  Future<void> init();

  /// Sort [items] using platform-native collation.
  ///
  /// Tuning parameters are backend-specific — each backend ignores
  /// parameters it does not support:
  /// - Pigeon (CompareStringEx): [direction], [caseSensitive],
  ///   [diacriticInsensitive]
  /// - FFI (ICU): [direction], [strength], [decomposition], [numeric]
  FutureOr<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  });

  /// Pigeon (MethodChannel → CompareStringEx) backend.
  ///
  /// Always available — no native library loading required.
  factory WindowsSort.pigeon() = _WindowsPigeonSort;

  /// FFI (OS-bundled ICU) backend.
  ///
  /// Loads `icu.dll` / `icuin.dll` via [init].  Throws if the library
  /// cannot be resolved; catch the error to fall back to another backend.
  factory WindowsSort.ffi({CollationLibraryLoader? loader}) = WindowsFfiSort;
}

final class _WindowsPigeonSort implements WindowsSort {
  final CollationWindowsHostApi _host = CollationWindowsHostApi();

  _WindowsPigeonSort();

  @override
  Future<void> init() async {}

  @override
  Future<List<CollationWindowsItem>> sort(
    List<CollationWindowsItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) async {
    final request = CollationWindowsRequest(
      items: items,
      locale: locale?.toLanguageTag(),
      direction: direction?.value,
      caseSensitive: caseSensitive,
      diacriticInsensitive: diacriticInsensitive,
    );
    return _host.sort(request);
  }
}

/// Per-platform options for Windows.
///
/// Use the named constructors for convenience:
/// - [SortOptionsWindows.ffi] — pre-selects the ICU-backed FFI backend
///   and exposes its tuning parameters.
/// - [SortOptionsWindows.pigeon] — pre-selects the CompareStringEx-backed
///   Pigeon backend and exposes its tuning parameters.
///
/// The unnamed constructor exposes all parameters for advanced use;
/// when [sort] is `null` the delegate defaults to [WindowsSort.ffi].
abstract interface class SortOptionsWindows {
  /// Collation locale; `null` means system default.
  Locale? get locale;

  /// Sort implementation (defaults to [WindowsSort.ffi] when `null`).
  WindowsSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  /// ICU collation strength (defaults to tertiary when `null`).
  /// Only used by the FFI (ICU) backend.
  CollatorStrength? get strength;

  /// Unicode normalisation mode (defaults to canonical when `null`).
  /// Only used by the FFI (ICU) backend.
  CollatorDecomposition? get decomposition;

  /// Whether to use natural numeric ordering (defaults to `true`).
  /// Only used by the FFI (ICU) backend.
  bool? get numeric;

  /// Whether case differences affect sort order.
  /// `null` or `false` (default) ignores case; `true` makes
  /// comparison case-sensitive.  Only used by the Pigeon backend.
  bool? get caseSensitive;

  /// Whether diacritics are ignored.
  /// `null` or `false` (default) treats diacritics as distinct;
  /// `true` ignores them.  Only used by the Pigeon backend.
  bool? get diacriticInsensitive;

  /// Optional async fallback invoked when the selected backend fails to
  /// initialize.
  ///
  /// When the selected [sort] (or the default) throws during
  /// [WindowsSort.init] (e.g. the FFI ICU library is not found), this
  /// callback is called.  It must return a replacement [WindowsSort]
  /// (typically `WindowsSort.pigeon()`), or `null` to propagate the
  /// failure as a [StateError].
  ///
  /// When the callback itself is `null` (the default), no fallback is
  /// attempted and the load error is thrown.
  FutureOr<WindowsSort?> Function()? get onLoadFailed;

  /// Unnamed constructor — all params, no pre-selected backend.
  const factory SortOptionsWindows({
    Locale? locale,
    WindowsSort? sort,
    SortDirection direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    bool? caseSensitive,
    bool? diacriticInsensitive,
    FutureOr<WindowsSort?> Function()? onLoadFailed,
  }) = _SortOptionsWindowsImpl;

  /// FFI (ICU) backend — pre-selects [WindowsSort.ffi].
  ///
  /// Only exposes ICU-relevant tuning parameters.
  factory SortOptionsWindows.ffi({
    Locale? locale,
    SortDirection direction = SortDirection.ascending,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
    CollationLibraryLoader? loader,
    FutureOr<WindowsSort?> Function()? onLoadFailed,
  }) => SortOptionsWindows(
    locale: locale,
    sort: WindowsSort.ffi(loader: loader),
    direction: direction,
    strength: strength,
    decomposition: decomposition,
    numeric: numeric,
    onLoadFailed: onLoadFailed,
  );

  /// Pigeon (CompareStringEx) backend — pre-selects [WindowsSort.pigeon].
  ///
  /// Only exposes CompareStringEx-relevant tuning parameters.
  factory SortOptionsWindows.pigeon({
    Locale? locale,
    SortDirection direction = SortDirection.ascending,
    bool? caseSensitive,
    bool? diacriticInsensitive,
  }) => SortOptionsWindows(
    locale: locale,
    sort: WindowsSort.pigeon(),
    direction: direction,
    caseSensitive: caseSensitive,
    diacriticInsensitive: diacriticInsensitive,
  );
}

class _SortOptionsWindowsImpl implements SortOptionsWindows {
  @override
  final Locale? locale;
  @override
  final WindowsSort? sort;
  @override
  final SortDirection direction;
  @override
  final CollatorStrength? strength;
  @override
  final CollatorDecomposition? decomposition;
  @override
  final bool? numeric;
  @override
  final bool? caseSensitive;
  @override
  final bool? diacriticInsensitive;

  @override
  final FutureOr<WindowsSort?> Function()? onLoadFailed;

  const _SortOptionsWindowsImpl({
    this.locale,
    this.sort,
    this.direction = SortDirection.ascending,
    this.strength,
    this.decomposition,
    this.numeric,
    this.caseSensitive,
    this.diacriticInsensitive,
    this.onLoadFailed,
  });
}
