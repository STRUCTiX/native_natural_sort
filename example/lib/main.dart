import 'package:flutter/material.dart';
import 'dart:async';

import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sortResult = '';

  @override
  void initState() {
    super.initState();
    initSort();
  }

  Future<void> initSort() async {
    try {
      final sort = NativeSort();
      await sort.init(SortOptions());
      final sorted = await sort.sort([
        SortItem(id: 'a', value: 'file10.txt'),
        SortItem(id: 'b', value: 'file2.txt'),
        SortItem(id: 'c', value: 'file1.txt'),
      ]);
      if (!mounted) return;
      setState(() {
        _sortResult = sorted.map((i) => i.id).join(', ');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sortResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Text('Sorted: $_sortResult'),
        ),
      ),
    );
  }
}
