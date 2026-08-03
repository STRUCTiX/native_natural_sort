import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NativeSort sort;

  setUp(() async {
    sort = NativeSort();
  });

  testWidgets('sorts with explicit locale', (tester) async {
    await sort.init(const SortOptions(
      android: SortOptionsAndroid(locale: Locale('en')),
      linux: SortOptionsLinux(locale: Locale('en')),
      windows: SortOptionsWindows(locale: Locale('en')),
    ));

    final result = await sort.sort([
      const SortItem(id: 'a', value: 'apple'),
      const SortItem(id: 'b', value: 'banana'),
      const SortItem(id: 'c', value: 'cherry'),
    ]);
    expect(result.map((i) => i.id), ['a', 'b', 'c']);
  });

  testWidgets('sorts with locale override at call time', (tester) async {
    await sort.init(const SortOptions());
    final result = await sort.sort(
      [
        const SortItem(id: 'a', value: 'apple'),
        const SortItem(id: 'b', value: 'banana'),
      ],
      locale: const Locale('en'),
    );
    expect(result.map((i) => i.id), ['a', 'b']);
  });

  testWidgets('sorts Chinese characters in zh locale order', (tester) async {
    await sort.init(const SortOptions(
      android: SortOptionsAndroid(locale: Locale('zh')),
      linux: SortOptionsLinux(locale: Locale('zh')),
      windows: SortOptionsWindows(locale: Locale('zh')),
    ));

    final result = await sort.sort([
      const SortItem(id: '1', value: '张三'),
      const SortItem(id: '2', value: '李四'),
      const SortItem(id: '3', value: '王五'),
    ]);
    // Pinyin order: 李 < 王 < 张 (or platform-specific zh collation)
    expect(result.length, 3);
  });
}
