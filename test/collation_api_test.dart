import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_natural_sort/native_natural_sort.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CollationApi', () {
    test('sortStrings sends request and receives sorted ids', () async {
      // Set up a mock message handler that returns a pre-sorted list of ids.
      const channel =
          'dev.flutter.pigeon.native_natural_sort.CollationHostApi.sortStrings';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channel, (ByteData? message) async {
        final codec = const StandardMessageCodec();
        return codec.encodeMessage(<Object?>[
          <Object?>['id3', 'id1', 'id2'],
        ]);
      });

      final result = await CollationApi.instance.sortStrings(
        CollationRequest(
          items: [
            CollationItem(id: 'id1', value: 'banana'),
            CollationItem(id: 'id2', value: 'cherry'),
            CollationItem(id: 'id3', value: 'apple'),
          ],
        ),
      );
      expect(result, ['id3', 'id1', 'id2']);
    });
  });

  group('CollationItem', () {
    test('equality', () {
      final a = CollationItem(id: 'a', value: 'x');
      final b = CollationItem(id: 'a', value: 'x');
      final c = CollationItem(id: 'a', value: 'y');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('CollationRequest', () {
    test('equality', () {
      final a = CollationRequest(items: [CollationItem(id: 'a', value: 'x')]);
      final b = CollationRequest(items: [CollationItem(id: 'a', value: 'x')]);
      final c = CollationRequest(
        items: [CollationItem(id: 'a', value: 'x')],
        locale: 'en',
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
