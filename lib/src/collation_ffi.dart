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

/// Compares [a] and [b] by collation order: negative if [a] sorts first,
/// zero if collation-equal, positive if [b] sorts first.
typedef CollationCompareFn = int Function(String a, String b);

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

/// Contract for platform-native ICU collation engines.
///
/// Engine lifecycle is managed by the caller — call [dispose]
/// to release the native collator.
abstract interface class IcuCollator {
  /// Compares [a] and [b] by collation order.
  int compare(String a, String b);

  /// Releases the native collator.
  void dispose();
}

/// Contract for resolving a platform-native ICU library and producing
/// collation engines.
///
/// Implemented by `LinuxCollationLoader` (Linux) and
/// `WindowsCollationLoader` (Windows).
abstract interface class CollationLibraryLoader {
  /// Whether the native ICU library was resolved successfully.
  bool get isAvailable;

  /// Resolves the native ICU library and its function pointers.
  Future<void> init();

  /// Returns a new collator for [localeName].
  IcuCollator collator(String? localeName);

  /// Releases the library handle.
  void dispose();
}

/// Base for platform FFI collation engines (Linux / Windows).
///
/// Receives pre-resolved ICU C function pointers from the loader,
/// opens a collator for [localeName] with numeric ordering enabled
/// via the `-u-kn` locale keyword, and compares strings pairwise
/// with `ucol_strcoll`.
///
/// Numeric ordering must be requested at open time — setting the
/// UCOL_NUMERIC_COLLATION attribute afterwards has no effect — and sort
/// keys cannot represent numeric order ("2"/"10" collapse to equal keys),
/// hence direct `ucol_strcoll` comparison.
abstract class CollatorBase implements IcuCollator {
  CollatorBase({
    required UcolOpenDart ucolOpen,
    required UcolCloseDart ucolClose,
    required UcolStrCollDart ucolStrColl,
    required String? localeName,
  }) : _ucolOpen = ucolOpen,
       _ucolClose = ucolClose,
       _ucolStrColl = ucolStrColl {
    _coll = _openCollator(localeName);
  }

  final UcolOpenDart _ucolOpen;
  final UcolCloseDart _ucolClose;
  final UcolStrCollDart _ucolStrColl;
  late final Pointer<Void> _coll;

  Pointer<Void> _openCollator(String? localeName) {
    final hasLocale = localeName != null && localeName.isNotEmpty;
    final base = hasLocale ? localeName : Platform.localeName;
    final normalized = base.replaceAll('_', '-');
    // Numeric ordering is a locale keyword (`-u-kn`) requested at open
    // time; setting UCOL_NUMERIC_COLLATION afterwards is a no-op.
    final locale = '${normalized.isEmpty ? 'en' : normalized}-u-kn';
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
      return coll;
    } finally {
      calloc.free(status);
      malloc.free(locPtr);
    }
  }

  @override
  void dispose() => _ucolClose(_coll);

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

extension CollatorSort on IcuCollator {
  /// Returns a new list sorted by collation order.
  ///
  /// Ties are broken by [idOf].  Set [descending] to `true` for
  /// reverse order.
  List<T> sort<T>(
    List<T> items, {
    required String Function(T) idOf,
    required String Function(T) valueOf,
    bool descending = false,
  }) {
    if (items.isEmpty) return items;
    return [...items]..sort((a, b) {
      final cmp = compare(valueOf(a), valueOf(b));
      if (cmp != 0) return descending ? -cmp : cmp;
      final idCmp = idOf(a).compareTo(idOf(b));
      return descending ? -idCmp : idCmp;
    });
  }
}
