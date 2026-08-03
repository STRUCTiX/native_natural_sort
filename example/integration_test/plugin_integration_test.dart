import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sort test', (WidgetTester tester) async {
    final sort = NativeSort();
    await sort.init(SortOptions());
    final result = await sort.sort([
      SortItem(id: 'a', value: 'file10.txt'),
      SortItem(id: 'b', value: 'file2.txt'),
      SortItem(id: 'c', value: 'file1.txt'),
    ]);
    // Natural sort: file1 < file2 < file10
    expect(result.map((i) => i.id), ['c', 'b', 'a']);
  });
}
