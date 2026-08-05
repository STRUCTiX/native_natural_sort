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

import '../collation.dart';

class LinuxCollationLoader implements CollationLibraryLoader {
  @override
  bool get isInitialized => false;

  @override
  Future<void> init() async =>
      throw UnsupportedError('Linux collation unavailable on this platform');

  @override
  IcuCollator collator(
    String? localeName, {
    bool numeric = true,
    int? strength,
    int? decomposition,
  }) => throw UnsupportedError('Linux collation unavailable on this platform');

  @override
  void dispose() {}
}
