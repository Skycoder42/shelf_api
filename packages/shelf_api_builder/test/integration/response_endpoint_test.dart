// ignore_for_file: discarded_futures

import 'dart:convert';
import 'dart:io';

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

  test('/noContent endpoint returns nothing', () {
    final responseFuture = server.apiClient.responseNoContent();
    expect(responseFuture, completion(isNull));
  });

  test('/noContent endpoint returns correct status code', () async {
    final response = await server.apiClient.responseNoContentRaw();
    expect(response.statusCode, HttpStatus.noContent);
  });

  test('/text endpoint returns correct data', () async {
    final response = await server.apiClient.responseText();
    expect(response, 'Hello, World!');
  });

  test('/text endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseTextRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, 'Hello, World!');
  });

  test('/binary endpoint returns correct data', () async {
    final response = await server.apiClient.responseBinary();
    expect(response, const [1, 2, 3, 4, 5]);
  });

  test('/binary endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseBinaryRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const [1, 2, 3, 4, 5]);
  });

  test('/json endpoint returns correct data', () async {
    final response = await server.apiClient.responseJson();
    expect(response, const BasicModel(42));
  });

  test('/json endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseJsonRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const BasicModel(42));
  });

  test('/json/list endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonList();
    expect(response, const [1, 2, 3]);
  });

  test('/json/list endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseJsonListRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const [1, 2, 3]);
  });

  test('/json/map endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonMap();
    expect(response, const {'a': BasicModel(1), 'b': BasicModel(2)});
  });

  test('/json/map endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseJsonMapRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const {'a': BasicModel(1), 'b': BasicModel(2)});
  });

  test('/json/custom endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonCustom();
    expect(response, const BasicModel(24));
  });

  test('/json/custom endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseJsonCustomRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const BasicModel(24));
  });

  test('/response endpoint returns correct data', () async {
    final response = await server.apiClient.responseResponse();
    expect(response.statusCode, HttpStatus.accepted);
    expect(response.contentLength, 13);
    expect(
      response.headers,
      containsPair('X-Extra-Data', ['Extra Header Data']),
    );
    expect(
      response.stream.cast<List<int>>().transform(utf8.decoder).join(),
      completion('Hello, World!'),
    );
  });

  test('/response/typed endpoint returns correct data', () async {
    final response = await server.apiClient.responseTypedResponse();
    expect(response, 'Hello, World!');
  });

  test('/response/typed endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseTypedResponseRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(
      response.headers.map,
      containsPair('X-Extra-Data', ['Extra Header Data']),
    );
    expect(response.data, 'Hello, World!');
  });

  test('/async/noContent endpoint returns nothing', () {
    final responseFuture = server.apiClient.responseAsyncNoContent();
    expect(responseFuture, completion(isNull));
  });

  test('/async/noContent endpoint returns correct status code', () async {
    final response = await server.apiClient.responseAsyncNoContentRaw();
    expect(response.statusCode, HttpStatus.noContent);
  });

  test('/async/text endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncText();
    expect(response, 'Hello, World!');
  });

  test('/async/text endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncTextRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, 'Hello, World!');
  });

  test('/async/binary endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncBinary();
    expect(response, const [1, 2, 3, 4, 5]);
  });

  test('/async/binary endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncBinaryRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const [1, 2, 3, 4, 5]);
  });

  test('/async/json endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncJson();
    expect(response, 4224);
  });

  test('/async/json endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncJson(asNull: true);
    expect(response, isNull);
  });

  test('/async/json endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncJsonRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, 4224);
  });

  test('/async/json/list endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncJsonList();
    expect(response, const [BasicModel(1), BasicModel(2), BasicModel(3)]);
  });

  test('/async/json/list endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncJsonList(asNull: true);
    expect(response, isNull);
  });

  test('/async/json/list endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncJsonListRaw(
      asNull: true,
    );
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, isNull);
  });

  test('/async/json/map endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncJsonMap();
    expect(response, const {'a': 1, 'b': 2});
  });

  test('/async/json/map endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncJsonMap(asNull: true);
    expect(response, isNull);
  });

  test('/async/json/map endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncJsonMapRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, const {'a': 1, 'b': 2});
  });

  test('/async/json/custom endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncJsonCustom();
    expect(response, const BasicModel(42));
  });

  test('/async/json/custom endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncJsonCustom(
      asNull: true,
    );
    expect(response, isNull);
  });

  test('/async/json/custom endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncJsonCustomRaw(
      asNull: true,
    );
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data, isNull);
  });

  test('/async/response endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncResponse();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.contentLength, 13);
    expect(response.headers, containsPair('X-As-Null', ['false']));
    expect(
      response.stream.cast<List<int>>().transform(utf8.decoder).join(),
      completion('Hello, World!'),
    );
  });

  test('/async/response endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncResponse(asNull: true);
    expect(response.statusCode, HttpStatus.noContent);
    expect(response.contentLength, 0);
    expect(response.headers, containsPair('X-As-Null', ['true']));
    expect(response.stream.isEmpty, completion(true));
  });

  test('/async/response/typed endpoint returns correct data', () async {
    final response = await server.apiClient.responseAsyncTypedResponse();
    expect(response, const BasicModel(11));
  });

  test('/async/response/typed endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseAsyncTypedResponseRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.headers.map, containsPair('X-As-Null', ['false']));
    expect(response.data, const BasicModel(11));
  });

  test('/async/response/typed endpoint returns null data', () async {
    final response = await server.apiClient.responseAsyncTypedResponse(
      asNull: true,
    );
    expect(response, isNull);
  });

  test('/async/response/typed endpoint returns null data raw', () async {
    final response = await server.apiClient.responseAsyncTypedResponseRaw(
      asNull: true,
    );
    expect(response.statusCode, HttpStatus.noContent);
    expect(response.headers.map, containsPair('X-As-Null', ['true']));
    expect(response.data, isNull);
  });

  test('/stream/text endpoint returns correct data', () {
    final response = server.apiClient.responseStreamText();
    expect(response.join(), completion('Hello, World!'));
  });

  test('/stream/text endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseStreamTextRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data.join(), completion('Hello, World!'));
  });

  test('/stream/binary endpoint returns correct data', () {
    final response = server.apiClient.responseStreamBinary();
    expect(response.collect(), completion([1, 2, 3, 4, 5]));
  });

  test('/stream/binary endpoint returns correct data raw', () async {
    final response = await server.apiClient.responseStreamBinaryRaw();
    expect(response.statusCode, HttpStatus.ok);
    expect(response.data.collect(), completion([1, 2, 3, 4, 5]));
  });
}
