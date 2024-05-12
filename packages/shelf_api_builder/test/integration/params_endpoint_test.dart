import 'dart:io';
import 'dart:math';

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

  test('/query accepts default values', () async {
    const testSValue = 'tree';
    final testUValue = Uri.https('example.com');
    final response = await server.apiClient.paramsGetQuery(
      sValue: testSValue,
      uValue: testUValue,
    );
    expect(response, {
      'sValue': testSValue,
      'oValue': null,
      'dValue': 42.0,
      'uValue': testUValue.toString(),
      'dtValue': null,
      's2Value': 's2',
    });
  });

  test('/query accepts all values', () async {
    const testSValue = 'tree';
    const testOValue = 123;
    const testDValue = 87.34;
    final testUValue = Uri.https('example.com');
    final testDtValue = DateTime.now();
    const testS2Value = 'another tree';

    final response = await server.apiClient.paramsGetQuery(
      sValue: testSValue,
      oValue: testOValue,
      dValue: testDValue,
      uValue: testUValue,
      dtValue: testDtValue,
      s2Value: testS2Value,
    );
    expect(response, {
      'sValue': testSValue,
      'oValue': testOValue,
      'dValue': testDValue,
      'uValue': testUValue.toString(),
      'dtValue': testDtValue.toIso8601String(),
      's2Value': testS2Value,
    });
  });

  test('/query/list accepts default values', () async {
    const testSValue = ['one', 'two', 'tree'];
    final testUValue = [Uri.http('example.com'), Uri.https('example.com')];
    final response = await server.apiClient.paramsGetQueryList(
      sValue: testSValue,
      uValue: testUValue,
    );
    expect(response, {
      'sValue': testSValue,
      'uValue': testUValue.toString(),
      'iValue': [1, 2, 3],
      'dtValue': '[]',
      's2Value': ['s2'],
    });
  });

  test('/query/list accepts all values', () async {
    const testSValue = ['one', 'two', 'tree'];
    final testUValue = [Uri.http('example.com'), Uri.https('example.com')];
    const testIValue = [2, 4, 8];
    final testDtValue = [DateTime.now()];
    const testS2Value = <String>[];
    final response = await server.apiClient.paramsGetQueryList(
      sValue: testSValue,
      uValue: testUValue,
      iValue: testIValue,
      dtValue: testDtValue,
      s2Value: testS2Value,
    );
    expect(response, {
      'sValue': testSValue,
      'uValue': testUValue.toString(),
      'iValue': testIValue,
      'dtValue': testDtValue.toString(),
      's2Value': ['s2'],
    });
  });

  test('/query/list returns bad request if required list is empty', () async {
    const testSValue = <String>[];
    final testUValue = <Uri>[];
    expect(
      () => server.apiClient.paramsGetQueryList(
        sValue: testSValue,
        uValue: testUValue,
      ),
      throwsA(
        isA<DioException>().having(
          (m) => m.response?.statusCode,
          'statusCode',
          HttpStatus.badRequest,
        ),
      ),
    );
  });

  test('/query/custom accepts default values', () async {
    const testNamedValue = 'tree';
    const testParsedValue = 'grass';
    final response = await server.apiClient.paramsGetQueryCustom(
      namedValue: testNamedValue,
      parsedValue: testParsedValue,
    );
    expect(response, {
      'namedValue': testNamedValue,
      'parsedValue': 'GRASSGRASSGRASS',
      'parsedListValue': ['unparsed', 'values'],
    });
  });

  test('/query/custom accepts all values', () async {
    const testNamedValue = 'tree';
    const testParsedValue = 'grass';
    const testParsedListValue = ['parsed', 'values'];
    final response = await server.apiClient.paramsGetQueryCustom(
      namedValue: testNamedValue,
      parsedValue: testParsedValue,
      parsedListValue: testParsedListValue,
    );
    expect(response, {
      'namedValue': testNamedValue,
      'parsedValue': 'GRASSGRASSGRASS',
      'parsedListValue': ['PARSEDPARSEDPARSED', 'VALUESVALUESVALUES'],
    });
  });

  test('/combined accepts path and query parameters', () async {
    const testP1 = pi;
    const testPrecision = 3;
    final response = await server.apiClient.paramsGetCombined(
      testP1,
      precision: testPrecision,
    );
    expect(response, {
      'p1': testP1,
      'precision': 3,
      'roundDown': false,
    });
  });
}
