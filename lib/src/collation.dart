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

/// Compares [a] and [b] by collation order: negative if [a] sorts first,
/// zero if collation-equal, positive if [b] sorts first.
typedef CollationCompareFn = int Function(String a, String b);

/// ICU attribute / value constants used by [CollatorBase].
abstract final class IcuAttr {
  IcuAttr._();

  static const int normalizationMode = 4;
  static const int numericCollation = 6;

  static const int strengthPrimary = 0;
  static const int strengthSecondary = 1;
  static const int strengthTertiary = 2;
  static const int strengthIdentical = 15;

  /// Maps [CollatorStrength] enum values to ICU UCollationStrength.
  static int mapStrength(int dartStrengthValue) => switch (dartStrengthValue) {
    0 => strengthPrimary,
    1 => strengthSecondary,
    2 => strengthTertiary,
    3 => strengthIdentical,
    _ => strengthTertiary,
  };

  static const int normNone = 1;
  static const int normNfd = 2;
  static const int normNfkd = 3;

  /// Maps [CollatorDecomposition] enum values to ICU UNormalizationMode.
  static int mapDecomposition(int dartDecompValue) => switch (dartDecompValue) {
    0 => normNone,
    1 => normNfd,
    2 => normNfkd,
    _ => normNfd,
  };
}

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
///
/// [init] must be called before [collator].  It is safe to call [init]
/// multiple times — only the first invocation performs resolution;
/// subsequent calls return the same future.  If resolution fails the
/// error is thrown to the caller (no silent fallback).
abstract interface class CollationLibraryLoader {
  /// Whether [init] has completed successfully.
  ///
  /// Returns `true` after a successful [init] call, `false` before
  /// initialization or after a failed attempt.  Derived from the
  /// internal [Completer.isCompleted] state — no separate flag.
  bool get isInitialized;

  /// Resolves the native ICU library and its function pointers.
  ///
  /// Throws if the library cannot be found or symbols cannot be resolved.
  Future<void> init();

  /// Returns a new collator for [localeName].
  ///
  /// [numeric], [strength], and [decomposition] are optional tuning
  /// parameters forwarded to the underlying [CollatorBase].
  IcuCollator collator(
    String? localeName, {
    bool numeric,
    int? strength,
    int? decomposition,
  });

  /// Releases the library handle.
  void dispose();
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
