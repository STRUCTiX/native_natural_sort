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

import 'package:flutter/foundation.dart';

import 'android/delegate.dart';
import 'android/sort.dart' show SortOptionsAndroid;
import 'delegate.dart';
import 'ios/delegate.dart';
import 'ios/sort.dart' show SortOptionsIOS;
import 'linux/delegate_stub.dart' if (dart.library.io) 'linux/delegate.dart';
import 'linux/sort.dart' show SortOptionsLinux;
import 'macos/delegate.dart';
import 'macos/sort.dart' show SortOptionsMacOS;
import 'web/delegate.dart';
import 'web/sort.dart' show SortOptionsWeb;
import 'windows/delegate_stub.dart'
    if (dart.library.io) 'windows/delegate.dart';
import 'windows/sort.dart' show SortOptionsWindows;

/// Sort direction for collation ordering.
enum SortDirection {
  /// Ascending order (default).
  ascending(0),

  /// Descending order.
  descending(1);

  final int value;
  const SortDirection(this.value);
}

/// An id/value pair for collation sorting.
class SortItem {
  /// Opaque identifier returned in the sorted result.
  final String id;

  /// String whose collation order determines the sort position.
  final String value;

  const SortItem({required this.id, required this.value});

  @override
  bool operator ==(Object other) =>
      other is SortItem && id == other.id && value == other.value;

  @override
  int get hashCode => Object.hash(id, value);

  @override
  String toString() => 'SortItem(id: $id, value: $value)';
}

/// Holds optional per-platform configuration sections.  Each platform
/// implementation picks its own section and ignores the rest.
class SortOptions {
  /// Android-specific options.
  final SortOptionsAndroid? android;

  /// iOS-specific options.
  final SortOptionsIOS? ios;

  /// macOS-specific options.
  final SortOptionsMacOS? macOS;

  /// Linux-specific options.
  final SortOptionsLinux? linux;

  /// Windows-specific options.
  final SortOptionsWindows? windows;

  /// Web-specific options.
  final SortOptionsWeb? web;

  const SortOptions({
    this.android,
    this.ios,
    this.macOS,
    this.linux,
    this.windows,
    this.web,
  });
}

/// Unified platform-native string collation.
///
/// Usage:
///
/// ```dart
/// final sort = NativeSort();
/// await sort.config(SortOptions(
///   android: SortOptionsAndroid(locale: Locale('zh')),
/// ));
/// final sorted = await sort.sort([
///   SortItem(id: 'a', value: 'file10.txt'),
///   SortItem(id: 'b', value: 'file2.txt'),
/// ]);
/// ```
///
/// [NativeSort] returns a platform-appropriate singleton — calling
/// the constructor multiple times returns the same instance.
class NativeSort {
  static final NativeSort _singleton = NativeSort._();
  static NativeSort? _testInstance;

  /// Returns the current platform's singleton.
  ///
  /// The first call creates the platform-appropriate instance;
  /// subsequent calls return the same instance.  When
  /// [instance] has been set for testing, that mock is returned.
  factory NativeSort() => _testInstance ?? _singleton;

  /// Inject a mock for testing (replaces the singleton).
  @visibleForTesting
  static set instance(NativeSort? value) => _testInstance = value;

  /// Reset the singleton to a fresh, uninitialized instance for testing.
  @visibleForTesting
  static void reset() {
    _testInstance = NativeSort._();
  }

  late PlatformDelegate _delegate;
  Completer<void>? _configCompleter;
  bool _isConfigured = false;

  NativeSort._();

  static PlatformDelegate _resolveDelegate() {
    if (kIsWeb) return WebDelegate();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidDelegate();
      case TargetPlatform.iOS:
        return IOSDelegate();
      case TargetPlatform.macOS:
        return MacOSDelegate();
      case TargetPlatform.linux:
        return LinuxDelegate();
      case TargetPlatform.windows:
        return WindowsDelegate();
      default:
        throw UnsupportedError('native_natural_sort: unsupported platform');
    }
  }

  /// Configures the native collation engine with [options].
  ///
  /// Each call creates a fresh platform delegate and initializes it,
  /// replacing any previous configuration.  A custom [delegate] may be
  /// injected to override the platform default.
  ///
  /// Concurrent calls are deduplicated — only the first takes effect
  /// and all callers receive the same future.  On FFI platforms (Linux,
  /// Windows) this resolves native libraries; on Pigeon platforms it is
  /// a no-op.
  Future<void> config(SortOptions options, {PlatformDelegate? delegate}) async {
    if (_configCompleter != null) return _configCompleter!.future;

    _configCompleter = Completer<void>();
    try {
      _delegate = delegate ?? _resolveDelegate();
      await _delegate.init(options);
      _isConfigured = true;
      _configCompleter!.complete();
      _configCompleter = null; // allow reconfiguration
    } catch (e) {
      _configCompleter!.complete();
      _configCompleter = null; // allow retry
      rethrow;
    }
  }

  /// Sorts [items] by the collation order of their values and
  /// returns the items in that order.
  ///
  /// [direction] overrides the default set via [config] options.
  /// [locale] overrides the default set via [config] options.
  /// Throws [StateError] if [config] has not been called first.
  FutureOr<List<SortItem>> sort(
    List<SortItem> items, {
    SortDirection? direction,
    Locale? locale,
  }) {
    if (!_isConfigured) throw StateError('Call config() first');
    final delegate = _delegate;
    return delegate.sort(items, direction: direction, locale: locale);
  }

  /// Casts the platform delegate to [T].
  ///
  /// The caller is responsible for ensuring the platform matches [T];
  /// a failed cast throws a [TypeError].
  ///
  /// ```dart
  /// final android = sort.resolveAs<AndroidDelegate>();
  /// await android.sortWith(items, numeric: false);
  /// ```
  T resolveAs<T extends PlatformDelegate>() => _delegate as T;
}
