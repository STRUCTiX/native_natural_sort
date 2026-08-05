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
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:native_natural_sort/native_natural_sort_io.dart';

class OptionsState extends ChangeNotifier {
  final NativeSort _sort;

  Locale? _locale;
  SortDirection _direction = SortDirection.ascending;
  CollatorStrength _strength = CollatorStrength.tertiary;
  CollatorDecomposition _decomposition = CollatorDecomposition.canonical;
  bool _numeric = true;
  bool _caseSensitive = false;
  bool _diacriticInsensitive = false;
  bool _useWindowsFfi = true;
  bool _lastUseWindowsFfi = true;
  bool _configured = false;
  bool _isAdvanced = true;

  OptionsState() : _sort = NativeSort();

  Locale? get locale => _locale;
  SortDirection get direction => _direction;
  CollatorStrength get strength => _strength;
  CollatorDecomposition get decomposition => _decomposition;
  bool get numeric => _numeric;
  bool get caseSensitive => _caseSensitive;
  bool get diacriticInsensitive => _diacriticInsensitive;
  bool get useWindowsFfi => _useWindowsFfi;
  bool get isConfigured => _configured;
  bool get isAdvanced => _isAdvanced;

  set isAdvanced(bool v) {
    if (_isAdvanced == v) return;
    _isAdvanced = v;
    notifyListeners();
  }

  set locale(Locale? v) { _locale = v; notifyListeners(); }
  set direction(SortDirection v) { _direction = v; notifyListeners(); }
  set strength(CollatorStrength v) { _strength = v; notifyListeners(); }
  set decomposition(CollatorDecomposition v) { _decomposition = v; notifyListeners(); }
  set numeric(bool v) { _numeric = v; notifyListeners(); }
  set caseSensitive(bool v) { _caseSensitive = v; notifyListeners(); }
  set diacriticInsensitive(bool v) { _diacriticInsensitive = v; notifyListeners(); }
  set useWindowsFfi(bool v) { _useWindowsFfi = v; notifyListeners(); }

  SortOptions buildSortOptions() => SortOptions(
    android: SortOptionsAndroid(
      locale: _locale,
      direction: _direction,
      strength: _strength,
      decomposition: _decomposition,
      numeric: _numeric,
    ),
    ios: SortOptionsIOS(
      locale: _locale,
      direction: _direction,
      caseSensitive: _caseSensitive,
      diacriticInsensitive: _diacriticInsensitive,
    ),
    macOS: SortOptionsMacOS(
      locale: _locale,
      direction: _direction,
      caseSensitive: _caseSensitive,
      diacriticInsensitive: _diacriticInsensitive,
    ),
    linux: SortOptionsLinux(
      locale: _locale,
      direction: _direction,
      strength: _strength,
      decomposition: _decomposition,
      numeric: _numeric,
    ),
    windows: _useWindowsFfi
        ? SortOptionsWindows.ffi(
            locale: _locale,
            direction: _direction,
            strength: _strength,
            decomposition: _decomposition,
            numeric: _numeric,
          )
        : SortOptionsWindows.pigeon(
            locale: _locale,
            direction: _direction,
            caseSensitive: _caseSensitive,
            diacriticInsensitive: _diacriticInsensitive,
          ),
    web: SortOptionsWeb(
      locale: _locale,
      direction: _direction,
      strength: _strength,
      decomposition: _decomposition,
      numeric: _numeric,
    ),
  );

  Future<void> configure() async {
    await _sort.config(buildSortOptions());
    _configured = true;
    _lastUseWindowsFfi = _useWindowsFfi;
  }

  Future<List<SortItem>> sortBasic(List<SortItem> items) async {
    _isAdvanced = false;
    await configure();
    return _sort.sort(items, direction: _direction, locale: _locale);
  }

  Future<List<SortItem>> sortAdvanced(List<SortItem> items) async {
    _isAdvanced = true;
    if (_lastUseWindowsFfi != _useWindowsFfi) await configure();

    if (kIsWeb) {
      return _sort.resolveAs<WebDelegate>().sortWith(
        items,
        locale: _locale,
        direction: _direction,
        strength: _strength,
        decomposition: _decomposition,
        numeric: _numeric,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _sort.resolveAs<AndroidDelegate>().sortWith(
          items,
          locale: _locale,
          direction: _direction,
          strength: _strength,
          decomposition: _decomposition,
          numeric: _numeric,
        );
      case TargetPlatform.iOS:
        return _sort.resolveAs<IOSDelegate>().sortWith(
          items,
          locale: _locale,
          direction: _direction,
          caseSensitive: _caseSensitive,
          diacriticInsensitive: _diacriticInsensitive,
        );
      case TargetPlatform.macOS:
        return _sort.resolveAs<MacOSDelegate>().sortWith(
          items,
          locale: _locale,
          direction: _direction,
          caseSensitive: _caseSensitive,
          diacriticInsensitive: _diacriticInsensitive,
        );
      case TargetPlatform.linux:
        return _sort.resolveAs<LinuxDelegate>().sortWith(
          items,
          locale: _locale,
          direction: _direction,
          strength: _strength,
          decomposition: _decomposition,
          numeric: _numeric,
        );
      case TargetPlatform.windows:
        return _sort.resolveAs<WindowsDelegate>().sortWith(
          items,
          locale: _locale,
          direction: _direction,
          strength: _strength,
          decomposition: _decomposition,
          numeric: _numeric,
          caseSensitive: _caseSensitive,
          diacriticInsensitive: _diacriticInsensitive,
        );
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
