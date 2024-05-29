import 'dart:io';

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

  test('/ endpoint applies global and endpoint middleware', () async {
    final response = await server.apiClient.middlewareGet();
    expect(response.statusCode, HttpStatus.noContent);
    expect(response.headers, containsPair('X-Api', ['shelf_api']));
    expect(
      response.headers,
      containsPair('X-Middleware', ['Api, Endpoint, Response']),
    );
    expect(response.headers, containsPair('X-Extra', ['extra']));
  });
}
