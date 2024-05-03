import 'package:dart_test_tools/test.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:test/test.dart';

void main() {
  group('HttpMethod', () {
    testData<(String, String)>(
      'provides correct verbs',
      [
        (HttpMethod.connect, 'CONNECT'),
        (HttpMethod.delete, 'DELETE'),
        (HttpMethod.get, 'GET'),
        (HttpMethod.head, 'HEAD'),
        (HttpMethod.options, 'OPTIONS'),
        (HttpMethod.patch, 'PATCH'),
        (HttpMethod.post, 'POST'),
        (HttpMethod.put, 'PUT'),
        (HttpMethod.trace, 'TRACE'),
      ],
      (fixture) {
        expect(fixture.$1, fixture.$2);
      },
    );

    test('value report all verbs', () {
      expect(HttpMethod.values, [
        'CONNECT',
        'DELETE',
        'GET',
        'HEAD',
        'OPTIONS',
        'PATCH',
        'POST',
        'PUT',
        'TRACE',
      ]);
    });
  });
}
