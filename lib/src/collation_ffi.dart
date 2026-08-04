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

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'collation.dart';

/// `UCollator* ucol_open(const char* loc, UErrorCode* status)`
typedef UcolOpenNative = Pointer<Void> Function(Pointer<Uint8>, Pointer<Int32>);
typedef UcolOpenDart = Pointer<Void> Function(Pointer<Uint8>, Pointer<Int32>);

/// `void ucol_close(UCollator* coll)`
typedef UcolCloseNative = Void Function(Pointer<Void>);
typedef UcolCloseDart = void Function(Pointer<Void>);

/// `int32_t ucol_strcoll(const UCollator* coll, const UChar* s1,
/// int32_t len1, const UChar* s2, int32_t len2)`
typedef UcolStrCollNative =
    Int32 Function(
      Pointer<Void>,
      Pointer<Uint16>,
      Int32,
      Pointer<Uint16>,
      Int32,
    );
typedef UcolStrCollDart =
    int Function(Pointer<Void>, Pointer<Uint16>, int, Pointer<Uint16>, int);

/// `void ucol_setAttribute(UCollator*, UColAttribute, UColAttributeValue, UErrorCode*)`
typedef UcolSetAttributeNative =
    Void Function(Pointer<Void>, Int32, Int32, Pointer<Int32>);
typedef UcolSetAttributeDart =
    void Function(Pointer<Void>, int, int, Pointer<Int32>);

/// `void ucol_setStrength(UCollator*, UCollationStrength)`
typedef UcolSetStrengthNative = Void Function(Pointer<Void>, Int32);
typedef UcolSetStrengthDart = void Function(Pointer<Void>, int);

/// Base for platform FFI collation engines (Linux / Windows).
///
/// Receives pre-resolved ICU C function pointers from the loader,
/// opens a collator for [localeName] with configurable numeric ordering
/// via the `-u-kn` locale keyword, and compares strings pairwise
/// with `ucol_strcoll`.
///
/// [numeric] controls natural numeric ordering — it must be requested
/// at open time; setting the UCOL_NUMERIC_COLLATION attribute afterwards
/// has no effect.  Sort keys cannot represent numeric order
/// ("2"/"10" collapse to equal keys), hence direct `ucol_strcoll`
/// comparison is used.
///
/// [strength] and [decomposition] are Dart enum values from
/// `CollatorStrength` / `CollatorDecomposition`.  They are mapped to ICU
/// constants via [IcuAttr] and applied after the collator is opened.
/// `null` leaves the ICU default (tertiary / canonical) unchanged.
abstract class CollatorBase implements IcuCollator {
  CollatorBase({
    required UcolOpenDart ucolOpen,
    required UcolCloseDart ucolClose,
    required UcolStrCollDart ucolStrColl,
    required String? localeName,
    UcolSetAttributeDart? ucolSetAttribute,
    UcolSetStrengthDart? ucolSetStrength,
    bool numeric = true,
    int? strength,
    int? decomposition,
  }) : _ucolOpen = ucolOpen,
       _ucolClose = ucolClose,
       _ucolStrColl = ucolStrColl,
       _ucolSetAttribute = ucolSetAttribute,
       _ucolSetStrength = ucolSetStrength {
    _coll = _openCollator(
      localeName,
      numeric: numeric,
      strength: strength,
      decomposition: decomposition,
    );
  }

  final UcolOpenDart _ucolOpen;
  final UcolCloseDart _ucolClose;
  final UcolStrCollDart _ucolStrColl;
  final UcolSetAttributeDart? _ucolSetAttribute;
  final UcolSetStrengthDart? _ucolSetStrength;
  late final Pointer<Void> _coll;

  Pointer<Void> _openCollator(
    String? localeName, {
    required bool numeric,
    int? strength,
    int? decomposition,
  }) {
    final hasLocale = localeName != null && localeName.isNotEmpty;
    final base = hasLocale ? localeName : Platform.localeName;
    final normalized = base.replaceAll('_', '-');
    // ICU requires an IETF BCP 47 language tag; fall back to 'en' when the
    // system locale is a POSIX / C locale or otherwise not a usable tag.
    final needsFallback = normalized.isEmpty || _isPosixLocale(normalized);
    final effectiveLocale = needsFallback ? 'en' : normalized;
    final keywordSuffix = numeric ? '-u-kn' : '';
    final locale = '$effectiveLocale$keywordSuffix';
    final locPtr = locale.toNativeUtf8(allocator: malloc);
    final status = calloc<Int32>()..value = 0;
    try {
      final coll = _ucolOpen(locPtr.cast<Uint8>(), status);
      // Only positive status is an error (U_FAILURE); negative values are
      // warnings (e.g. U_USING_DEFAULT_WARNING) and still yield a valid
      // collator using fallback data.
      if (status.value > 0 || coll == nullptr) {
        if (coll != nullptr) _ucolClose(coll);
        throw UnsupportedError(
          'ucol_open failed for "$locale": UErrorCode=${status.value}',
        );
      }
      // Apply optional tuning attributes after open.
      if (strength != null && _ucolSetStrength != null) {
        _ucolSetStrength(coll, IcuAttr.mapStrength(strength));
      }
      if (decomposition != null && _ucolSetAttribute != null) {
        status.value = 0;
        _ucolSetAttribute(
          coll,
          IcuAttr.normalizationMode,
          IcuAttr.mapDecomposition(decomposition),
          status,
        );
      }
      return coll;
    } finally {
      calloc.free(status);
      malloc.free(locPtr);
    }
  }

  @override
  void dispose() => _ucolClose(_coll);

  /// Whether [tag] is a POSIX / C locale that ICU cannot use as a
  /// BCP 47 language tag.
  static bool _isPosixLocale(String tag) {
    // POSIX and C locales start with exactly "C" or "POSIX", possibly
    // followed by a dot and encoding (e.g. "C.UTF-8", "POSIX").
    return tag == 'C' ||
        tag == 'POSIX' ||
        tag.startsWith('C.') ||
        tag.startsWith('POSIX.');
  }

  /// Compares [a] and [b] via [ucol_strcoll] (numeric-aware).
  @override
  int compare(String a, String b) => using((arena) {
    final pa = a.toNativeUtf16(allocator: arena);
    final pb = b.toNativeUtf16(allocator: arena);
    return _ucolStrColl(
      _coll,
      pa.cast<Uint16>(),
      a.length,
      pb.cast<Uint16>(),
      b.length,
    );
  });
}

/// Non-fatal variant of [DynamicLibrary.lookupFunction].
///
/// Returns `null` instead of throwing [ArgumentError] when the named
/// native function is not exported by the library.
///
/// Accepts plain FFI function typedefs directly — no need to wrap the
/// native signature in [NativeFunction]:
///
/// ```dart
/// final fn = lib.tryLookup<UcolSetAttributeNative, UcolSetAttributeDart>(
///   'ucol_setAttribute',
/// );
/// ```
///
/// See [DynamicLibrary.lookupFunction] for the full type contract.
extension TryLookup on DynamicLibrary {
  D? tryLookup<T, D extends Function>(String symbolName) {
    try {
      // Dynamic dispatch bypasses the static-type limitation that prevents
      // generic wrappers around lookupFunction — the compiler allows the
      // call directly on DynamicLibrary but not through a generic indirection.
      return (this as dynamic).lookupFunction<T, D>(symbolName) as D;
    } on ArgumentError {
      return null;
    }
  }
}
