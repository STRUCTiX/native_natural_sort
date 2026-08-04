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

  UcolOpenDart? _ucolOpen;
  UcolCloseDart? _ucolClose;
  UcolStrCollDart? _ucolStrColl;

  WindowsCollationLoader();

  @override
  bool get isAvailable => _available;

  @override
  Future<void> init() async {
    if (_available) return;
    try {
      if (_searchAndLoad()) {
        _resolveFunctions();
        return;
      }
    } catch (_) {
      _available = false;
    }
  }

  bool _searchAndLoad() {
    for (final candidate in _dllCandidates) {
      if (_tryLoad(candidate)) return true;
    }
    return false;
  }

  bool _tryLoad(String candidate) {
    DynamicLibrary? open(String name) {
      try {
        return DynamicLibrary.open(name);
      } catch (_) {
        return null;
      }
    }

    final lib = open(candidate);
    if (lib == null) return false;
    if (!_hasSymbols(lib)) return false;
    _lib = lib;
    _available = true;
    return true;
  }

  @override
  IcuCollator collator(String? localeName) => WindowsCollator(
    ucolOpen: _ucolOpen!,
    ucolClose: _ucolClose!,
    ucolStrColl: _ucolStrColl!,
    localeName: localeName,
  );

  @override
  void dispose() {
    _lib = null;
    _available = false;
  }

  void _resolveFunctions() {
    final lib = _requireLib();
    _ucolOpen = lib.lookupFunction<UcolOpenNative, UcolOpenDart>('ucol_open');
    _ucolClose = lib.lookupFunction<UcolCloseNative, UcolCloseDart>(
      'ucol_close',
    );
    _ucolStrColl = lib.lookupFunction<UcolStrCollNative, UcolStrCollDart>(
      'ucol_strcoll',
    );
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

final class WindowsCollator extends CollatorBase {
  WindowsCollator({
    required super.ucolOpen,
    required super.ucolClose,
    required super.ucolStrColl,
    required super.localeName,
  });
}
