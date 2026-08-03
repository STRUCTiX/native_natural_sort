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
    dartOut: 'lib/src/ios/collation_api.g.dart',
    swiftOut: 'ios/Classes/CollationApi.g.swift',
    dartOptions: DartOptions(),
  ),
)
/// An id/value pair for collation sorting.
class CollationIOSItem {
  CollationIOSItem({required this.id, required this.value});

  /// Opaque identifier returned in the sorted result.
  String id;

  /// String whose collation order determines the sort position.
  String value;
}

/// Request to sort [items] by the collation order of their [value]s.
///
/// iOS uses `compare(_:options:range:locale:)` —
/// [CollationIOSItem.id]s are returned in collation order.
///
/// [locale] selects the Foundation locale identifier (e.g. "en_US").
/// When `null`, the system locale is used.
///
/// [direction] sets sort direction: 0 = ascending (default),
/// 1 = descending.
///
/// [caseSensitive] controls whether case differences affect sort
/// order.  `null` (default) uses case-insensitive comparison.
///
/// [diacriticInsensitive] controls whether diacritics are ignored.
/// `null` (default) treats diacritics as distinct; `true` treats
/// "é" as "e".
class CollationIOSRequest {
  CollationIOSRequest({
    required this.items,
    this.locale,
    this.direction,
    this.caseSensitive,
    this.diacriticInsensitive,
  });

  List<CollationIOSItem> items;
  String? locale;
  int? direction;
  bool? caseSensitive;
  bool? diacriticInsensitive;
}

/// Platform-native string collation.
@HostApi()
abstract class CollationIOSHostApi {
  /// Returns [request.items]' ids reordered so that their corresponding
  /// values are in collation order.
  List<CollationIOSItem> sort(CollationIOSRequest request);
}
