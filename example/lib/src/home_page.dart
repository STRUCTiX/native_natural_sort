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

import 'options_state.dart';
import 'platform_info.dart';
import 'sort_dialog.dart';
import 'sort_list_data.dart';

const _kPresetLocales = <({String code, String label})>[
  (code: '', label: 'System'),
  (code: 'en', label: 'en'),
  (code: 'en_US', label: 'en_US'),
  (code: 'de', label: 'de'),
  (code: 'fr', label: 'fr'),
  (code: 'es', label: 'es'),
  (code: 'zh', label: 'zh'),
  (code: 'zh_Hans', label: 'zh_Hans'),
  (code: 'ja', label: 'ja'),
  (code: 'ko', label: 'ko'),
  (code: 'ar', label: 'ar'),
  (code: 'ru', label: 'ru'),
  (code: 'sv', label: 'sv'),
  (code: 'da', label: 'da'),
];

int _localeIndex(Locale? locale) {
  if (locale == null) return 0;
  final tag = locale.toLanguageTag();
  final i = _kPresetLocales.indexWhere((e) => e.code == tag);
  return i >= 0 ? i : 0;
}

Locale? _parseLocale(String code) {
  if (code.isEmpty) return null;
  final parts = code.split('_');
  return Locale(parts.first, parts.length > 1 ? parts[1] : null);
}

String _directionLabel(SortDirection d) =>
    d == SortDirection.ascending ? 'Asc' : 'Desc';

String _strengthLabel(CollatorStrength s) => switch (s) {
  CollatorStrength.primary => 'Pri',
  CollatorStrength.secondary => 'Sec',
  CollatorStrength.tertiary => 'Ter',
  CollatorStrength.identical => 'Idn',
};

String _decompLabel(CollatorDecomposition d) => switch (d) {
  CollatorDecomposition.none => 'None',
  CollatorDecomposition.canonical => 'Can',
  CollatorDecomposition.full => 'Full',
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OptionsState _opts = OptionsState();
  List<SortItem>? _items;
  String? _error;
  bool _sorting = false;

  @override
  void initState() {
    super.initState();
    _opts.addListener(_onOptionsChanged);
    _doInitialSort();
  }

  @override
  void dispose() {
    _opts.removeListener(_onOptionsChanged);
    super.dispose();
  }

  void _onOptionsChanged() {
    if (mounted) setState(() {});
    _resort();
  }

  Future<void> _doInitialSort() async {
    try {
      await _opts.configure();
      final result = await _opts.sortAdvanced(kTestItems);
      if (mounted) setState(() => _items = result);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _resort() async {
    if (_sorting || _items == null) return;
    _sorting = true;
    try {
      final result = _opts.isAdvanced
          ? await _opts.sortAdvanced(kTestItems)
          : await _opts.sortBasic(kTestItems);
      if (mounted) setState(() => _items = result);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      _sorting = false;
    }
  }

  Future<void> _openDialog() async {
    final result = await SortDialog.show(context, _opts);
    if (result != null && mounted) setState(() => _items = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Natural Sort'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openDialog,
        tooltip: 'Sort Options',
        child: const Icon(Icons.tune),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) return _buildError();
    if (_items == null) return _buildLoading();
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ConfigHeaderDelegate(opts: _opts),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          sliver: SliverList.builder(
            itemCount: _items!.length,
            itemBuilder: (context, index) {
              final item = _items![index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
                ),
                title: Text(item.value),
                subtitle: Text(
                  item.id,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _items = null;
                });
                _doInitialSort();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigHeaderDelegate extends SliverPersistentHeaderDelegate {
  final OptionsState opts;

  _ConfigHeaderDelegate({required this.opts});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final elevated = shrinkOffset > 0;
    return Material(
      elevation: elevated ? 2 : 0,
      shadowColor: elevated ? Colors.black26 : Colors.transparent,
      child: _ConfigBar(opts: opts),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _ConfigHeaderDelegate old) => true;
}

class _ConfigBar extends StatelessWidget {
  final OptionsState opts;

  const _ConfigBar({required this.opts});

  static const _kTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final advanced = opts.isAdvanced;
    final filters = <Widget>[
      _FilterDropdown<bool>(
        value: advanced,
        color: advanced ? scheme.primary : scheme.outline,
        items: const [
          DropdownMenuItem(
            value: false,
            child: Text('Basic', style: _kTextStyle),
          ),
          DropdownMenuItem(
            value: true,
            child: Text('Adv', style: _kTextStyle),
          ),
        ],
        onChanged: (v) => opts.isAdvanced = v,
      ),
      _FilterDropdown<SortDirection>(
        value: opts.direction,
        color: scheme.tertiary,
        items: SortDirection.values
            .map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(_directionLabel(d), style: _kTextStyle),
                ))
            .toList(),
        onChanged: (v) => opts.direction = v,
      ),
      _FilterDropdown<int>(
        value: _localeIndex(opts.locale),
        color: scheme.primary,
        items: List.generate(
          _kPresetLocales.length,
          (i) => DropdownMenuItem(
            value: i,
            child: Text(_kPresetLocales[i].label, style: _kTextStyle),
          ),
        ),
        onChanged: (i) {
          final code = _kPresetLocales[i].code;
          opts.locale = _parseLocale(code);
        },
      ),
    ];

    if (advanced && supportsNumeric) {
      filters.add(_FilterDropdown<bool>(
        value: opts.numeric,
        color: scheme.secondary,
        items: const [
          DropdownMenuItem(value: true, child: Text('Num', style: _kTextStyle)),
          DropdownMenuItem(value: false, child: Text('Lex', style: _kTextStyle)),
        ],
        onChanged: (v) => opts.numeric = v,
      ));
    }

    if (advanced && supportsStrength) {
      filters.add(_FilterDropdown<CollatorStrength>(
        value: opts.strength,
        color: scheme.error,
        items: CollatorStrength.values
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(_strengthLabel(s), style: _kTextStyle),
                ))
            .toList(),
        onChanged: (v) => opts.strength = v,
      ));
    }

    if (advanced && supportsDecomposition) {
      filters.add(_FilterDropdown<CollatorDecomposition>(
        value: opts.decomposition,
        color: scheme.onPrimaryContainer,
        items: CollatorDecomposition.values
            .map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(_decompLabel(d), style: _kTextStyle),
                ))
            .toList(),
        onChanged: (v) => opts.decomposition = v,
      ));
    }

    if (advanced && supportsCaseAndDiacritic) {
      filters.add(_FilterDropdown<bool>(
        value: opts.caseSensitive,
        color: scheme.error,
        items: const [
          DropdownMenuItem(value: false, child: Text('aa', style: _kTextStyle)),
          DropdownMenuItem(value: true, child: Text('Aa', style: _kTextStyle)),
        ],
        onChanged: (v) => opts.caseSensitive = v,
      ));
      filters.add(_FilterDropdown<bool>(
        value: opts.diacriticInsensitive,
        color: scheme.onPrimaryContainer,
        items: const [
          DropdownMenuItem(value: false, child: Text('ã', style: _kTextStyle)),
          DropdownMenuItem(value: true, child: Text('Noã', style: _kTextStyle)),
        ],
        onChanged: (v) => opts.diacriticInsensitive = v,
      ));
    }

    if (advanced && isWindows) {
      filters.add(_FilterDropdown<bool>(
        value: opts.useWindowsFfi,
        color: scheme.primary,
        items: const [
          DropdownMenuItem(value: true, child: Text('FFI', style: _kTextStyle)),
          DropdownMenuItem(value: false, child: Text('Pgn', style: _kTextStyle)),
        ],
        onChanged: (v) => opts.useWindowsFfi = v,
      ));
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: scheme.surfaceContainerHighest,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters,
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final Color color;
  final ValueChanged<T> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(100)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            items: items,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            icon: Icon(Icons.arrow_drop_down, size: 16, color: color),
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

