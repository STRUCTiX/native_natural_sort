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

import 'package:flutter/material.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

// ── Locale ────────────────────────────────────────────────────────

const _kPresetLocales = <({String code, String label})>[
  (code: '', label: 'System default'),
  (code: 'en', label: 'English (en)'),
  (code: 'en_US', label: 'English US (en_US)'),
  (code: 'de', label: 'Deutsch (de)'),
  (code: 'fr', label: 'Français (fr)'),
  (code: 'es', label: 'Español (es)'),
  (code: 'zh', label: '中文 (zh)'),
  (code: 'zh_Hans', label: '简体中文 (zh_Hans)'),
  (code: 'ja', label: '日本語 (ja)'),
  (code: 'ko', label: '한국어 (ko)'),
  (code: 'ar', label: 'العربية (ar)'),
  (code: 'ru', label: 'Русский (ru)'),
  (code: 'sv', label: 'Svenska (sv)'),
  (code: 'da', label: 'Dansk (da)'),
];

class LocaleSelector extends StatelessWidget {
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  const LocaleSelector({super.key, required this.value, required this.onChanged});

  static int _localeIndex(Locale? locale) {
    if (locale == null) return 0;
    final tag = locale.toLanguageTag();
    final i = _kPresetLocales.indexWhere((e) => e.code == tag);
    return i >= 0 ? i : 0;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _localeIndex(value),
      decoration: const BorderInputDecoration(label: 'Collation locale'),
      items: List.generate(_kPresetLocales.length, (i) {
        final entry = _kPresetLocales[i];
        return DropdownMenuItem(value: i, child: Text(entry.label));
      }),
      onChanged: (i) {
        if (i == null) return;
        final code = _kPresetLocales[i].code;
        onChanged(code.isEmpty ? null : _parseLocale(code));
      },
    );
  }

  static Locale _parseLocale(String code) {
    final parts = code.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }
}

class BorderInputDecoration extends InputDecoration {
  const BorderInputDecoration({required String label})
    : super(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      );
}

// ── Direction ─────────────────────────────────────────────────────

class DirectionSelector extends StatelessWidget {
  final SortDirection value;
  final ValueChanged<SortDirection> onChanged;

  const DirectionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _kLabel = {
    SortDirection.ascending: 'Ascending',
    SortDirection.descending: 'Descending',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sort direction',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SegmentedButton<SortDirection>(
            segments: SortDirection.values.map((d) {
              return ButtonSegment<SortDirection>(
                value: d,
                label: Text(_kLabel[d] ?? d.name),
              );
            }).toList(),
            selected: {value},
            onSelectionChanged: (sel) => onChanged(sel.first),
          ),
        ],
      ),
    );
  }
}

// ── Strength ──────────────────────────────────────────────────────

class StrengthSelector extends StatelessWidget {
  final CollatorStrength value;
  final ValueChanged<CollatorStrength> onChanged;

  const StrengthSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _kLabel = {
    CollatorStrength.primary: 'Primary',
    CollatorStrength.secondary: 'Secondary',
    CollatorStrength.tertiary: 'Tertiary',
    CollatorStrength.identical: 'Identical',
  };

  static const _kTooltip = {
    CollatorStrength.primary: 'Base letter only (a ≠ b, a = A = á)',
    CollatorStrength.secondary: 'Letter + accent (a ≠ á, a = A)',
    CollatorStrength.tertiary: 'Letter + accent + case (a ≠ A) — default',
    CollatorStrength.identical: 'All differences including punctuation',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Collation strength',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SegmentedButton<CollatorStrength>(
            segments: CollatorStrength.values.map((s) {
              return ButtonSegment<CollatorStrength>(
                value: s,
                label: Text(_kLabel[s] ?? s.name),
                tooltip: _kTooltip[s],
              );
            }).toList(),
            selected: {value},
            onSelectionChanged: (sel) => onChanged(sel.first),
          ),
        ],
      ),
    );
  }
}

// ── Decomposition ─────────────────────────────────────────────────

class DecompositionSelector extends StatelessWidget {
  final CollatorDecomposition value;
  final ValueChanged<CollatorDecomposition> onChanged;

  const DecompositionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _kLabel = {
    CollatorDecomposition.none: 'None',
    CollatorDecomposition.canonical: 'Canonical',
    CollatorDecomposition.full: 'Full',
  };

  static const _kTooltip = {
    CollatorDecomposition.none: 'No decomposition',
    CollatorDecomposition.canonical: 'Canonical (NFD) — default',
    CollatorDecomposition.full: 'Full (NFKD) — also decomposes compatibility chars',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Decomposition mode',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SegmentedButton<CollatorDecomposition>(
            segments: CollatorDecomposition.values.map((d) {
              return ButtonSegment<CollatorDecomposition>(
                value: d,
                label: Text(_kLabel[d] ?? d.name),
                tooltip: _kTooltip[d],
              );
            }).toList(),
            selected: {value},
            onSelectionChanged: (sel) => onChanged(sel.first),
          ),
        ],
      ),
    );
  }
}

// ── Numeric ───────────────────────────────────────────────────────

class NumericSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NumericSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Natural numeric ordering'),
      subtitle: const Text(
        'When on, "file2" < "file10". When off, lexicographic order.',
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Case sensitive ────────────────────────────────────────────────

class CaseSensitiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CaseSensitiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Case sensitive'),
      subtitle: const Text(
        'When on, "A" ≠ "a". Only used by Apple / Windows Pigeon backends.',
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Diacritic ─────────────────────────────────────────────────────

class DiacriticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DiacriticSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Ignore diacritics'),
      subtitle: const Text(
        'When on, "é" = "e". Only used by Apple / Windows Pigeon backends.',
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Windows FFI ───────────────────────────────────────────────────

class WindowsFfiSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const WindowsFfiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Use FFI (ICU) backend'),
      subtitle: Text(
        value
            ? 'Dart FFI → OS-bundled ICU (supports strength / numeric)'
            : 'MethodChannel → CompareStringEx (supports case / diacritic)',
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
