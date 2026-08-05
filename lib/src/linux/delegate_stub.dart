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

import '../common.dart';
import '../delegate.dart';
import '../sort.dart';

class LinuxDelegate extends PlatformDelegate {
  @override
  Future<void> init(SortOptions options) async =>
      throw UnsupportedError('Linux collation unavailable on this platform');

  @override
  FutureOr<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) => throw UnsupportedError('Linux collation unavailable on this platform');

  List<SortItem> sortWith(
    List<SortItem> items, {
    Locale? locale,
    SortDirection? direction,
    CollatorStrength? strength,
    CollatorDecomposition? decomposition,
    bool? numeric,
  }) => throw UnsupportedError('Linux collation unavailable on this platform');
}
