@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/src/collation_cache.dart';

void main() {
  group('CollationCache.inMemory', () {
    late CollationCache cache;

    setUp(() {
      cache = CollationCache.inMemory();
    });

    test('read returns null when nothing has been written', () async {
      expect(await cache.read(), isNull);
    });

    test('write then read round-trips the value', () async {
      await cache.write('hello');
      expect(await cache.read(), 'hello');
    });

    test('write overwrites previous value', () async {
      await cache.write('first');
      await cache.write('second');
      expect(await cache.read(), 'second');
    });

    test('write then read then write then read', () async {
      await cache.write('a');
      expect(await cache.read(), 'a');
      await cache.write('b');
      expect(await cache.read(), 'b');
    });
  });

  group('CollationCache.file', () {
    late String tmpPath;
    late CollationCache cache;

    setUp(() {
      tmpPath =
          '${Directory.systemTemp.path}/native_natural_sort_cache_test_${DateTime.now().microsecondsSinceEpoch}';
      cache = CollationCache.file(tmpPath);
    });

    tearDown(() async {
      final file = File(tmpPath);
      if (await file.exists()) await file.delete();
    });

    test('read returns null when file does not exist', () async {
      expect(await cache.read(), isNull);
    });

    test('write creates file and read returns the value', () async {
      await cache.write('persisted');
      expect(await cache.read(), 'persisted');
    });

    test('write overwrites file content', () async {
      await cache.write('v1');
      await cache.write('v2');
      expect(await cache.read(), 'v2');
    });

    test('two caches pointing to the same path share data', () async {
      final cache2 = CollationCache.file(tmpPath);
      await cache.write('shared');
      expect(await cache2.read(), 'shared');
    });

    test('read after file is externally deleted returns null', () async {
      await cache.write('temp');
      await File(tmpPath).delete();
      expect(await cache.read(), isNull);
    });
  });
}
