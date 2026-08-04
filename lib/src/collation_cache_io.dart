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

import 'dart:convert';
import 'dart:io';

import 'collation_cache.dart';

class FileCache implements CollationCache {
  final String _path;

  FileCache(String path) : _path = path;

  @override
  Future<String?> read() async {
    try {
      final file = File(_path);
      if (!await file.exists()) return null;
      return utf8.decode(await file.readAsBytes()).trim();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String value) async {
    try {
      await File(_path).writeAsBytes(utf8.encode(value));
    } catch (_) {
      // Best-effort.
    }
  }
}
