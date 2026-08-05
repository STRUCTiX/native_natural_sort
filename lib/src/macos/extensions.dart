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

import '../sort.dart';
import 'delegate.dart';

/// Convenience accessor for the macOS platform delegate.
///
/// ```dart
/// final sort = NativeSort();
/// await sort.config(SortOptions(
///   macOS: SortOptionsMacOS(caseSensitive: true),
/// ));
/// final result = await sort.macos.sortWith(items, diacriticInsensitive: true);
/// ```
extension NativeSortMacOSExtension on NativeSort {
  /// The [MacOSDelegate] backing this [NativeSort] instance.
  ///
  /// Throws a [TypeError] if the delegate is not an [MacOSDelegate].
  MacOSDelegate get macos => resolveAs<MacOSDelegate>();
}
