import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  late ExampleServer server;

  setUpAll(() async {
    server = await ExampleServer.start();
  });

  tearDownAll(() async {
    await server.stop();
  });

  test('basic endpoint returns data', () async {
    final response = await server.apiClient.basicGet();
    expect(response, 'Hello, World!');
  });
}
