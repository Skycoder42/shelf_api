import 'dart:convert';
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

  test('returns badRequest', () async {
    const testErrorMessage = 'this is a format error';
    final response = await server.getRaw(
      Uri.parse('/format'),
      testErrorMessage,
    );
    expect(response.statusCode, HttpStatus.badRequest);
    expect(
      response.transform(utf8.decoder).join(),
      completion(testErrorMessage),
    );
  });
}
