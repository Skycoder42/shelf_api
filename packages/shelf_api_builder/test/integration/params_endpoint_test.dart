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

  test('/path/simple endpoint correctly translates parameters', () async {
    const testP1 = 'tree';
    const testP2 = 12;
    final response = await server.apiClient.paramsGetPathSimple(testP1, testP2);
    expect(response, [testP1, testP2]);
  });

  test('/path/custom endpoint correctly translates parameters', () async {
    const testP1 = 'word';
    const testP2 = 'valid/sub/path';
    final response = await server.apiClient.paramsGetPathCustom(
      testP1,
      Uri.parse(testP2),
    );
    expect(response, ['WORDWORDWORD', testP2]);
  });

  test('/path/custom endpoint returns 404 for non matching params', () async {
    const testP1 = '';
    const testP2 = '/invalid';
    expect(
      () => server.apiClient.paramsGetPathCustom(
        testP1,
        Uri.parse(testP2),
      ),
      throwsA(
        isA<DioException>().having(
          (m) => m.response?.statusCode,
          'statusCode',
          HttpStatus.notFound,
        ),
      ),
    );
  });
}
