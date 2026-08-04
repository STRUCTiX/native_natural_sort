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
import 'dart:io';

import '../collation_cache.dart';
import '../collation_ffi.dart';

class LinuxCollationLoader implements CollationLibraryLoader {
  /// Shared cache key for the resolved library path.
  static const cacheKey = 'libicui18n_path';

  final CollationCache _cache;
  final IcuCollationLinuxRules _rules = IcuCollationLinuxRules();

  DynamicLibrary? _lib;
  String _icuVersionSuffix = '';
  String? _loadedPath;
  bool _available = false;

  UcolOpenDart? _ucolOpen;
  UcolCloseDart? _ucolClose;
  UcolStrCollDart? _ucolStrColl;

  LinuxCollationLoader({CollationCache? cache, List<String>? searchDirs})
    : _cache = cache ?? CollationCache.inMemory() {
    if (searchDirs != null) _searchDirs = searchDirs;
  }

  List<String>? _searchDirs;

  @override
  bool get isAvailable => _available;

  @override
  Future<void> init() async {
    if (_available) return;
    try {
      final cachedPath = await _cache.read();
      if (cachedPath != null && _tryLoadPath(cachedPath)) {
        _resolveFunctions();
        return;
      }

      if (await _searchAndLoad()) {
        final path = _loadedPath;
        if (path != null) await _cache.write(path);
        _resolveFunctions();
        return;
      }
    } catch (_) {
      _available = false;
    }
  }

  @override
  IcuCollator collator(String? localeName) => LinuxCollator(
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

  /// Applies a resolved library to the state.
  void _applyResolved(DynamicLibrary lib, String suffix, String path) {
    _lib = lib;
    _icuVersionSuffix = suffix;
    _loadedPath = path;
    _available = true;
  }

  void _resolveFunctions() {
    final lib = _requireLib();
    final suffix = _icuVersionSuffix;
    _ucolOpen = lib.lookupFunction<UcolOpenNative, UcolOpenDart>(
      'ucol_open$suffix',
    );
    _ucolClose = lib.lookupFunction<UcolCloseNative, UcolCloseDart>(
      'ucol_close$suffix',
    );
    _ucolStrColl = lib.lookupFunction<UcolStrCollNative, UcolStrCollDart>(
      'ucol_strcoll$suffix',
    );
  }

  /// Attempts to resolve [path], applying the state on success.
  bool _tryLoadPath(String path) {
    final result = _rules.tryLoadPath(path);
    if (result == null) return false;
    _applyResolved(result.$1, result.$2, path);
    return true;
  }

  Future<bool> _searchAndLoad() async {
    final dirs = _searchDirs ?? _rules.searchDirs;
    final discovered = await _rules.discoverCandidates(dirs);
    for (final candidate in _rules.candidates(discovered)) {
      if (_tryLoadPath(candidate)) return true;
    }
    return false;
  }

  DynamicLibrary _requireLib() {
    final lib = _lib;
    if (lib == null) {
      throw StateError('LinuxCollationLoader not resolved; call init() first');
    }
    return lib;
  }
}

final class LinuxCollator extends CollatorBase {
  LinuxCollator({
    required super.ucolOpen,
    required super.ucolClose,
    required super.ucolStrColl,
    required super.localeName,
  });
}

/// Pure `libicui18n` resolution rules for Linux.
///
/// Encapsulates which sonames/directories to probe, how to parse and order
/// candidates by ICU version, and how to validate a library (symbol probe).
/// Kept separate from the cache/load orchestration in `LinuxCollationLoader`
/// so the rules can be unit-tested in isolation.
final class IcuCollationLinuxRules {
  /// App-recommended stable ICU version, tried before the highest one
  /// discovered (widely deployed: Debian 12, Ubuntu 23.04+).
  static const recommendedVersion = 72;

  /// The Linux multiarch directory component for the current ABI.
  String get multiarchTriplet => switch (Abi.current()) {
    Abi.linuxArm64 => 'aarch64-linux-gnu',
    Abi.linuxX64 => 'x86_64-linux-gnu',
    Abi.linuxArm => 'arm-linux-gnueabihf',
    Abi.linuxRiscv64 => 'riscv64-linux-gnu',
    _ => 'x86_64-linux-gnu',
  };

  /// Directories scanned for `libicui18n.so*` (host + Flatpak layouts).
  List<String> get searchDirs => [
    '/usr/lib/$multiarchTriplet',
    '/lib/$multiarchTriplet',
    '/app/lib', // Flatpak runtime layout
  ];

  /// Candidate paths in resolution order: unversioned soname, then the
  /// recommended stable version, then the highest version in [discovered].
  List<String> candidates(List<String> discovered) => [
    'libicui18n.so',
    'libicui18n.so.$recommendedVersion',
    if (discovered.isNotEmpty) discovered.first,
  ];

  /// Lists `libicui18n.so*` files under [dirs] ordered by descending ICU
  /// major version (unversioned entries last).
  Future<List<String>> discoverCandidates(List<String> dirs) async {
    final found = <String>[];
    for (final dir in dirs) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      try {
        await for (final entity in directory.list(followLinks: true)) {
          if (entity is! File) continue;
          final path = entity.path;
          if (!path.split('/').last.startsWith('libicui18n.so')) continue;
          found.add(path);
        }
      } catch (_) {
        // Skip unreadable directories.
      }
    }
    found.sort(_byVersionDesc);
    return found;
  }

  int _byVersionDesc(String a, String b) {
    final va = extractVersionMajor(a);
    final vb = extractVersionMajor(b);
    if (va == null && vb == null) return a.compareTo(b);
    if (va == null) return 1;
    if (vb == null) return -1;
    if (va != vb) return vb.compareTo(va);
    return b.compareTo(a);
  }

  /// ICU major version from a soname path (`libicui18n.so.72.1` → 72),
  /// or `null` when unversioned (`libicui18n.so`).
  int? extractVersionMajor(String path) {
    final name = path.split('/').last;
    final match = RegExp(r'^libicui18n\.so\.(\d+)').firstMatch(name);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// ICU symbol-version suffix from a soname path:
  /// `libicui18n.so.72` → `_72`, `libicui18n.so` → `""`.
  String extractVersionSuffix(String path) {
    final major = extractVersionMajor(path);
    return major != null ? '_$major' : '';
  }

  /// Probes [lib] for a `ucol_open_XX` symbol — [preferred] version first,
  /// then the bare `ucol_open` (Flatpak-style unversioned exports) —
  /// returning the suffix or `null`.
  String? probeVersionSuffix(DynamicLibrary lib, {String preferred = ''}) {
    if (preferred.isNotEmpty) {
      try {
        lib.lookup<NativeFunction<Void Function()>>('ucol_open$preferred');
        return preferred;
      } on ArgumentError {
        // fall through to unversioned
      }
    }
    try {
      lib.lookup<NativeFunction<Void Function()>>('ucol_open');
      return '';
    } on ArgumentError {
      return null;
    }
  }

  /// Resolves [path] as a usable ICU library, returning the library and
  /// its symbol suffix, or `null` when [path] cannot be opened or probed.
  (DynamicLibrary, String)? tryLoadPath(String path) {
    DynamicLibrary lib;
    try {
      lib = DynamicLibrary.open(path);
    } catch (_) {
      return null;
    }
    final preferred = extractVersionSuffix(path);
    final suffix = probeVersionSuffix(lib, preferred: preferred);
    if (suffix == null) return null;
    return (lib, suffix);
  }
}
