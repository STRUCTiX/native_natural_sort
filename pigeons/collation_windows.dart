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

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/windows/collation_api.g.dart',
    cppHeaderOut: 'windows/collation_api.g.h',
    cppSourceOut: 'windows/collation_api.g.cpp',
    cppOptions: CppOptions(namespace: 'native_natural_sort'),
    dartOptions: DartOptions(),
  ),
)
/// An id/value pair for collation sorting.
class CollationWindowsItem {
  CollationWindowsItem({required this.id, required this.value});

  /// Opaque identifier returned in the sorted result.
  String id;

  /// String whose collation order determines the sort position.
  String value;
}

/// Request to sort [items] by the collation order of their [value]s.
///
/// [locale] selects the ICU collation locale.  When omitted, the
/// platform uses its system-default collator.
///
/// [direction] sets sort direction: 0 = ascending (default),
/// 1 = descending.
///
/// [caseSensitive] controls case sensitivity in comparison.
/// `null` or `false` (default) ignores case; `true` makes
/// comparison case-sensitive.
///
/// [diacriticInsensitive] when `true`, ignores diacritics
/// (accents) during comparison; `null` or `false` (default)
/// treats diacritics as distinct.
class CollationWindowsRequest {
  CollationWindowsRequest({
    required this.items,
    this.locale,
    this.direction,
    this.caseSensitive,
    this.diacriticInsensitive,
  });

  List<CollationWindowsItem> items;
  String? locale;
  int? direction;
  bool? caseSensitive;
  bool? diacriticInsensitive;
}

/// Platform-native string collation.
@HostApi()
abstract class CollationWindowsHostApi {
  /// Returns [request.items]' ids reordered so that their corresponding
  /// values are in collation order.
  List<CollationWindowsItem> sort(CollationWindowsRequest request);
}
