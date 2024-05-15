import 'package:dart_test_tools/test.dart';
import 'package:shelf_api/src/api/content_types.dart';
import 'package:test/test.dart';

void main() {
  group('ContentTypes', () {
    testData<(String, String)>(
      'provides correct verbs',
      [
        (ContentTypes.text, 'text/plain'),
        (ContentTypes.binary, 'application/octet-stream'),
        (ContentTypes.json, 'application/json'),
      ],
      (fixture) {
        expect(fixture.$1, fixture.$2);
      },
    );

    test('value report all verbs', () {
      expect(ContentTypes.values, [
        'text/plain',
        'application/octet-stream',
        'application/json',
      ]);
    });
  });
}
