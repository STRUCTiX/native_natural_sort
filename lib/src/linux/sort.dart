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

import '../collation.dart';
import '../common.dart';
import '../sort.dart';

import 'sort_stub.dart' if (dart.library.io) 'sort_ffi.dart';

/// Linux sort — Dart FFI → system libicui18n.
abstract interface class LinuxSort {
  /// Initialize the backend (load native libraries, resolve symbols).
  ///
  /// Must be called before [sort].  Safe to call multiple times —
  /// only the first invocation performs work.
  Future<void> init();

  List<SortItem> sort(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  });

  factory LinuxSort({CollationLibraryLoader? loader}) = LinuxSortImpl;
}

/// Per-platform options for Linux.
abstract interface class SortOptionsLinux {
  /// ICU collation locale; `null` means system default.
  Locale? get locale;

  /// Injectable sort implementation; `null` uses the default.
  LinuxSort? get sort;

  /// Sort direction (defaults to [SortDirection.ascending]).
  SortDirection get direction;

  /// ICU collation strength (defaults to tertiary when `null`).
  CollatorStrength? get strength;

  /// Unicode normalisation mode (defaults to canonical when `null`).
  CollatorDecomposition? get decomposition;

  /// Whether to use natural numeric ordering (defaults to `true`).
  bool? get numeric;

  const factory SortOptionsLinux({
    Locale? locale,
    LinuxSort? sort,
    SortDirection direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) = _SortOptionsLinuxImpl;
}

class _SortOptionsLinuxImpl implements SortOptionsLinux {
  @override
  final Locale? locale;
  @override
  final LinuxSort? sort;
  @override
  final SortDirection direction;
  @override
  final CollatorStrength? strength;
  @override
  final CollatorDecomposition? decomposition;
  @override
  final bool? numeric;
  const _SortOptionsLinuxImpl({
    this.locale,
    this.sort,
    this.direction = SortDirection.ascending,
    this.strength,
    this.decomposition,
    this.numeric,
  });
}
