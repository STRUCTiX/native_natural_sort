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

/// ICU collation strength level.
///
/// Controls whether case and accent differences affect sort order.
/// Maps to Android [java.text.Collator] strength constants.
enum CollatorStrength {
  /// Base letter differences only (a ≠ b, but a = A = á = À).
  primary(0),

  /// Base letter + accent differences (a ≠ á, but a = A).
  secondary(1),

  /// Base letter + accent + case differences (a ≠ A). Default.
  tertiary(2),

  /// All differences including punctuation.
  identical(3);

  final int value;
  const CollatorStrength(this.value);
}

/// Unicode normalisation mode for collation.
///
/// Controls whether composed characters are decomposed before comparison.
enum CollatorDecomposition {
  /// No decomposition.
  none(0),

  /// Canonical decomposition (NFD). Default.
  canonical(1),

  /// Full decomposition (NFKD) — also decomposes compatibility characters.
  full(2);

  final int value;
  const CollatorDecomposition(this.value);
}
