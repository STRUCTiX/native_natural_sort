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
import 'sort_controls.dart';
import 'sort_list_data.dart';

class SortDialog extends StatefulWidget {
  final OptionsState source;
  final int initialTab;

  const SortDialog({super.key, required this.source, required this.initialTab});

  static Future<List<SortItem>?> show(
    BuildContext context,
    OptionsState source,
  ) {
    final initialTab = source.isAdvanced ? 1 : 0;
    return Navigator.of(context).push<List<SortItem>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SortDialog(source: source, initialTab: initialTab),
      ),
    );
  }

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _sorting = false;

  late Locale? _locale;
  late SortDirection _direction;
  late CollatorStrength _strength;
  late CollatorDecomposition _decomposition;
  late bool _numeric;
  late bool _caseSensitive;
  late bool _diacriticInsensitive;
  late bool _useWindowsFfi;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _copyFrom(widget.source);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyFrom(OptionsState s) {
    _locale = s.locale;
    _direction = s.direction;
    _strength = s.strength;
    _decomposition = s.decomposition;
    _numeric = s.numeric;
    _caseSensitive = s.caseSensitive;
    _diacriticInsensitive = s.diacriticInsensitive;
    _useWindowsFfi = s.useWindowsFfi;
  }

  void _writeTo(OptionsState s) {
    s.locale = _locale;
    s.direction = _direction;
    s.strength = _strength;
    s.decomposition = _decomposition;
    s.numeric = _numeric;
    s.caseSensitive = _caseSensitive;
    s.diacriticInsensitive = _diacriticInsensitive;
    s.useWindowsFfi = _useWindowsFfi;
  }

  Future<void> _apply() async {
    setState(() => _sorting = true);
    try {
      _writeTo(widget.source);
      final isBasic = _tabController.index == 0;
      final result = isBasic
          ? await widget.source.sortBasic(kTestItems)
          : await widget.source.sortAdvanced(kTestItems);
      if (mounted) Navigator.of(context).pop(result);
    } finally {
      if (mounted) setState(() => _sorting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort Options'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicTab(),
                _buildAdvancedTab(),
              ],
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DirectionSelector(
          value: _direction,
          onChanged: (v) => setState(() => _direction = v),
        ),
        const SizedBox(height: 12),
        LocaleSelector(
          value: _locale,
          onChanged: (v) => setState(() => _locale = v),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Basic mode uses the generic NativeSort.sort() API\n'
              'with only direction & locale overrides.\n'
              'Calls config() before every sort.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DirectionSelector(
          value: _direction,
          onChanged: (v) => setState(() => _direction = v),
        ),
        const SizedBox(height: 12),
        LocaleSelector(
          value: _locale,
          onChanged: (v) => setState(() => _locale = v),
        ),
        const Divider(height: 24),

        if (supportsNumeric) ...[
          NumericSwitch(
            value: _numeric,
            onChanged: (v) => setState(() => _numeric = v),
          ),
          const Divider(height: 24),
        ],
        if (supportsStrength)
          StrengthSelector(
            value: _strength,
            onChanged: (v) => setState(() => _strength = v),
          ),
        if (supportsDecomposition)
          DecompositionSelector(
            value: _decomposition,
            onChanged: (v) => setState(() => _decomposition = v),
          ),

        if (supportsCaseAndDiacritic) ...[
          CaseSensitiveSwitch(
            value: _caseSensitive,
            onChanged: (v) => setState(() => _caseSensitive = v),
          ),
          const Divider(height: 24),
          DiacriticSwitch(
            value: _diacriticInsensitive,
            onChanged: (v) => setState(() => _diacriticInsensitive = v),
          ),
          const Divider(height: 24),
        ],

        if (isWindows) ...[
          WindowsFfiSwitch(
            value: _useWindowsFfi,
            onChanged: (v) => setState(() => _useWindowsFfi = v),
          ),
          const Divider(height: 24),
        ],

        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Advanced mode uses resolveAs<T>().sortWith()\n'
              'with all platform-specific parameters.\n'
              'Only re-configures on Windows backend switch.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _sorting ? null : _apply,
            child: _sorting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Apply'),
          ),
        ),
      ),
    );
  }
}
