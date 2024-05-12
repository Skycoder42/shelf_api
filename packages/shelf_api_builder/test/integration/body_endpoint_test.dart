import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_test_tools/test.dart';
import 'package:dio/dio.dart';
import 'package:shelf_api/builder_utils.dart';
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

  test('/text returns body as sent', () async {
    const testBody = 'Test Body';
    final response = await server.apiClient.bodyGetText(testBody);
    expect(response, testBody);
  });

  test('/binary returns body as sent', () async {
    final testBody = Uint8List.fromList([1, 2, 3, 4]);
    final response = await server.apiClient.bodyGetBinary(testBody);
    expect(response, testBody);
  });

  test('/stream/binary streams body as sent', () async {
    final testController = StreamController<List<int>>();

    final response = server.apiClient.bodyStreamBinary(
      testController.stream,
      $options: Options(
        headers: {
          Headers.contentLengthHeader: 15,
        },
      ),
    );
    expect(response.collect(), completion(List.generate(15, (i) => i)));

    testController
      ..add([0, 1, 2])
      ..add([3]);
    await Future.delayed(const Duration(milliseconds: 100));
    testController
      ..add([4, 5, 6, 7, 8, 9, 10])
      ..add([11, 12, 13, 14]);
    await testController.close();
  });

  test('/json returns body as sent', () async {
    const testBody = BasicModel(123);
    final response = await server.apiClient.bodyGetJson(testBody);
    expect(response, testBody);
  });

  test('/json returns bad request if request is empty', () async {
    expect(
      () => server.dio.get('/api/v1/body/json'),
      throwsA(
        isA<DioException>().having(
          (m) => m.response?.statusCode,
          'statusCode',
          HttpStatus.badRequest,
        ),
      ),
    );
  });

  test('/json/list returns body as sent', () async {
    const testBody = [2, 4, 6, 8];
    final response = await server.apiClient.bodyGetJsonList(testBody);
    expect(response, testBody);
  });

  test('/json/map returns body as sent', () async {
    const testBody = {
      'a': BasicModel(1),
      'b': BasicModel(2),
    };
    final response = await server.apiClient.bodyGetJsonMap(testBody);
    expect(response, testBody);
  });

  test('/json/custom returns body as sent', () async {
    const testBody = BasicModel(123);
    final response = await server.apiClient.bodyGetJsonCustom(testBody);
    expect(response, testBody);
  });

  testData('/json/null returns body as sent', const [null, 42],
      (testBody) async {
    final response = await server.apiClient.bodyGetJsonNull(testBody);
    expect(response, testBody);
  });

  testData('/json/null/list returns body as sent', const [
    null,
    [BasicModel(1), BasicModel(11)],
  ], (testBody) async {
    final response = await server.apiClient.bodyGetJsonNullList(testBody);
    expect(response, testBody);
  });

  testData('/json/null/map returns body as sent', const [
    null,
    {'x': 10, 'y': 20},
  ], (testBody) async {
    final response = await server.apiClient.bodyGetJsonNullMap(testBody);
    expect(response, testBody);
  });

  testData(
      '/json/null/custom returns body as sent', const [null, BasicModel(999)],
      (testBody) async {
    final response = await server.apiClient.bodyGetJsonNullCustom(testBody);
    expect(response, testBody);
  });
}
