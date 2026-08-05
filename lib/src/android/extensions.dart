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

/// Convenience accessor for the Android platform delegate.
///
/// Use `import 'package:native_natural_sort/native_natural_sort.dart'`
/// to include this extension, or append `hide NativeSortAndroidExtension`
/// to opt out.
///
/// ```dart
/// final sort = NativeSort();
/// await sort.init(SortOptions(
///   android: SortOptionsAndroid(strength: CollatorStrength.primary),
/// ));
/// final result = await sort.android.sortWith(items, numeric: false);
/// ```
extension NativeSortAndroidExtension on NativeSort {
  /// The [AndroidDelegate] backing this [NativeSort] instance.
  ///
  /// Throws a [TypeError] if the delegate is not an [AndroidDelegate].
  AndroidDelegate get android => resolveAs<AndroidDelegate>();
}
