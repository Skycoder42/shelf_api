import 'dart:io';

import 'package:test/test.dart';

import '../../example/basic_model.dart';
import 'test_helper.dart';

void main() {
  late ExampleServer server;

  setUpAll(() async {
    server = await ExampleServer.start();
  });

  tearDownAll(() async {
    await server.stop();
  });

  test('/ endpoint returns data', () async {
    final response = await server.apiClient.basicGet();
    expect(response, 'Hello, World!');
  });

  test('/ endpoint applies global middleware', () async {
    final response = await server.apiClient.basicGetRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.headers.map, containsPair('X-Api', ['shelf_api']));
    expect(response.headers.map, containsPair('X-Middleware', ['Api']));
  });

  test('/complex endpoint returns minimal data', () async {
    final response = await server.apiClient.basicComplexExampleRaw(
      42,
      const BasicModel(11),
      factor: 2,
    );
    expect(response.statusCode, HttpStatus.created);
    expect(response.data, const BasicModel(23));
    expect(
      response.headers.map,
      containsPair(HttpHeaders.locationHeader, ['/examples/42']),
    );
    expect(response.headers.map, isNot(contains('x-extra')));
    expect(response.headers.map, containsPair('X-Api', ['shelf_api']));
    expect(response.headers.map, containsPair('X-Middleware', ['Api']));
  });

  test('/complex endpoint returns full data', () async {
    const testExtra = 'test-extra';
    final response = await server.apiClient.basicComplexExampleRaw(
      25,
      const BasicModel(13),
      factor: 3,
      delta: 0.2,
      extra: testExtra,
    );
    expect(response.statusCode, HttpStatus.created);
    expect(response.data, const BasicModel(39));
    expect(
      response.headers.map,
      containsPair(HttpHeaders.locationHeader, ['/examples/25']),
    );
    expect(response.headers.map, containsPair('x-extra', [testExtra]));
    expect(response.headers.map, containsPair('X-Api', ['shelf_api']));
    expect(response.headers.map, containsPair('X-Middleware', ['Api']));
  });
}
