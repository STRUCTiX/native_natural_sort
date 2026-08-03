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

import '../collation_ffi.dart';

class WindowsCollationLoader implements CollationLibraryLoader {
  /// Windows system ICU candidates, most recent first.
  static const _dllCandidates = ['icu.dll', 'icuin.dll'];

  DynamicLibrary? _lib;
  bool _available = false;

  WindowsCollationLoader();

  @override
  bool get isAvailable => _available;

  @override
  Future<void> init() async {
    if (_available) return;
    for (final candidate in _dllCandidates) {
      try {
        final lib = DynamicLibrary.open(candidate);
        if (!_hasSymbols(lib)) continue;
        _lib = lib;
        _available = true;
        return;
      } catch (_) {
        continue;
      }
    }
    // Windows system ICU unavailable — natural sort falls back to platform.
  }

  @override
  IcuCollationEngine engine(String? localeName) =>
      WindowsCollationEngine(_requireLib(), '', localeName);

  @override
  void dispose() {
    _lib = null;
    _available = false;
  }

  /// Verifies the unversioned ICU entry symbols are exported by [lib].
  bool _hasSymbols(DynamicLibrary lib) {
    for (final symbol in const ['ucol_open', 'ucol_close', 'ucol_strcoll']) {
      try {
        lib.lookup<NativeFunction<Void Function()>>(symbol);
      } on ArgumentError {
        return false;
      }
    }
    return true;
  }

  DynamicLibrary _requireLib() {
    final lib = _lib;
    if (lib == null) {
      throw StateError(
        'WindowsCollationLoader not resolved; call init() first',
      );
    }
    return lib;
  }
}

final class WindowsCollationEngine extends CollationEngineBase {
  WindowsCollationEngine(super.lib, super.suffix, super.localeName);
}
