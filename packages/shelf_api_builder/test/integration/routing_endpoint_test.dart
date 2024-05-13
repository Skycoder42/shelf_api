import 'dart:io';

import 'package:dio/dio.dart';
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

  group('<empty>', () {
    test('HEAD / returns info header', () async {
      final response = await server.apiClient.rootRoutingHeadRoot();
      expect(
        response.headers,
        containsPair('X-INFO', ['HEAD /api/v1/']),
      );
    });

    test('GET / returns data', () async {
      final response = await server.apiClient.rootRoutingGetRoot();
      expect(response, 'GET /api/v1/');
    });

    test('GET <empty> returns notFound', () async {
      final response = await server.dio.get(
        '/api/v1',
        options: Options(validateStatus: (status) => true),
      );
      expect(response.statusCode, HttpStatus.notFound);
    });

    test('GET /path/open returns data', () async {
      final response = await server.apiClient.rootRoutingGetPathOpen();
      expect(response, 'GET /api/v1/path/open');
    });

    test('GET /path/open/ returns notFound', () async {
      final response = await server.dio.get(
        '/api/v1/path/open/',
        options: Options(validateStatus: (status) => true),
      );
      expect(response.statusCode, HttpStatus.notFound);
    });

    test('GET /path/closed/ returns data', () async {
      final response = await server.apiClient.rootRoutingGetPathClosed();
      expect(response, 'GET /api/v1/path/closed/');
    });

    test('GET /path/closed returns notFound', () async {
      final response = await server.dio.get(
        '/api/v1/path/closed',
        options: Options(validateStatus: (status) => true),
      );
      expect(response.statusCode, HttpStatus.notFound);
    });
  });

  group('/open', () {
    test('DELETE / returns data', () async {
      final response = await server.apiClient.openRoutingDeleteRoot();
      expect(response, 'DELETE /api/v1/open/');
    });

    test('DELETE <empty> returns data', () async {
      final response = await server.dio.delete<String>('/api/v1/open');
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, 'DELETE /api/v1/open');
    });

    test('OPTIONS /path/open returns data', () async {
      final response = await server.apiClient.openRoutingOptionsPathOpen();
      expect(response, 'OPTIONS /api/v1/open/path/open');
    });

    test('PATCH /path/closed/ returns data', () async {
      final response = await server.apiClient.openRoutingPatchPathClosed();
      expect(response, 'PATCH /api/v1/open/path/closed/');
    });
  });

  group('/closed/', () {
    test('POST / returns data', () async {
      final response = await server.apiClient.closedRoutingPostRoot();
      expect(response, 'POST /api/v1/closed/');
    });

    test('POST <empty> returns notFound', () async {
      final response = await server.dio.post(
        '/api/v1/closed',
        options: Options(validateStatus: (status) => true),
      );
      expect(response.statusCode, HttpStatus.notFound);
    });

    test('PUT /path/open returns data', () async {
      final response = await server.apiClient.closedRoutingPutPathOpen();
      expect(response, 'PUT /api/v1/closed/path/open');
    });

    test('TRACE /path/closed/ returns data', () async {
      final response = await server.apiClient.closedRoutingTracePathClosed();
      expect(response, 'TRACE /api/v1/closed/path/closed/');
    });
  });

  group('/', () {
    test('POST / returns data', () async {
      final response = await server.apiClient.slashRoutingPostRoot();
      expect(response, 'POST /api/v1/');
    });

    test('POST <empty> returns notFound', () async {
      final response = await server.dio.post(
        '/api/v1',
        options: Options(validateStatus: (status) => true),
      );
      expect(response.statusCode, HttpStatus.notFound);
    });

    test('POST /slash/open returns data', () async {
      final response = await server.apiClient.slashRoutingPostSlashOpen();
      expect(response, 'POST /api/v1/slash/open');
    });

    test('POST /slash/closed/ returns data', () async {
      final response = await server.apiClient.slashRoutingPostSlashClosed();
      expect(response, 'POST /api/v1/slash/closed/');
    });
  });
}
