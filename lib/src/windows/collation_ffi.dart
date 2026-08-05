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
import 'dart:ffi';

import '../collation_ffi.dart';

class WindowsCollationLoader implements CollationLibraryLoader {
  /// Windows system ICU candidates, most recent first.
  static const _dllCandidates = ['icu.dll', 'icuin.dll'];

  DynamicLibrary? _lib;
  Completer<void>? _initCompleter;

  UcolOpenDart? _ucolOpen;
  UcolCloseDart? _ucolClose;
  UcolStrCollDart? _ucolStrColl;
  UcolSetAttributeDart? _ucolSetAttribute;
  UcolSetStrengthDart? _ucolSetStrength;

  WindowsCollationLoader();

  @override
  bool get isInitialized => _initCompleter?.isCompleted == true;

  @override
  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    try {
      _searchAndLoad();
      _resolveFunctions();
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null; // allow retry
      rethrow;
    }
  }

  void _searchAndLoad() {
    for (final candidate in _dllCandidates) {
      if (_tryLoad(candidate)) return;
    }
    throw StateError(
      'WindowsCollationLoader: no ICU DLL found (tried: ${_dllCandidates.join(", ")})',
    );
  }

  bool _tryLoad(String candidate) {
    final DynamicLibrary lib;
    try {
      lib = DynamicLibrary.open(candidate);
    } catch (_) {
      return false;
    }
    if (!_hasSymbols(lib)) return false;
    _lib = lib;
    return true;
  }

  @override
  IcuCollator collator(
    String? localeName, {
    bool numeric = true,
    int? strength,
    int? decomposition,
  }) => WindowsCollator(
    ucolOpen: _ucolOpen!,
    ucolClose: _ucolClose!,
    ucolStrColl: _ucolStrColl!,
    ucolSetAttribute: _ucolSetAttribute,
    ucolSetStrength: _ucolSetStrength,
    localeName: localeName,
    numeric: numeric,
    strength: strength,
    decomposition: decomposition,
  );

  @override
  void dispose() {
    _lib = null;
    _initCompleter = null;
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
    try {
      _ucolSetAttribute = lib
          .lookupFunction<UcolSetAttributeNative, UcolSetAttributeDart>(
            'ucol_setAttribute',
          );
    } on ArgumentError {
      _ucolSetAttribute = null;
    }
    try {
      _ucolSetStrength = lib
          .lookupFunction<UcolSetStrengthNative, UcolSetStrengthDart>(
            'ucol_setStrength',
          );
    } on ArgumentError {
      _ucolSetStrength = null;
    }
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
    super.ucolSetAttribute,
    super.ucolSetStrength,
    required super.localeName,
    super.numeric = true,
    super.strength,
    super.decomposition,
  });
}
