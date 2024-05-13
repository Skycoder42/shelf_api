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

  test('/noContent endpoint returns nothing', () async {
    final responseFuture = server.apiClient.responseNoContent();
    expect(responseFuture, completion(isNull));
  });

  test('/text endpoint returns correct data', () async {
    final response = await server.apiClient.responseText();
    expect(response, 'Hello, World!');
  });

  test('/binary endpoint returns correct data', () async {
    final response = await server.apiClient.responseBinary();
    expect(response, const [1, 2, 3, 4, 5]);
  });

  test('/json endpoint returns correct data', () async {
    final response = await server.apiClient.responseJson();
    expect(response, const BasicModel(42));
  });

  test('/json/list endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonList();
    expect(response, const [1, 2, 3]);
  });

  test('/json/map endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonMap();
    expect(response, const {'a': BasicModel(1), 'b': BasicModel(2)});
  });

  test('/json/custom endpoint returns correct data', () async {
    final response = await server.apiClient.responseJsonCustom();
    expect(response, const BasicModel(24));
  });

  test('/response endpoint returns correct data', () async {
    final response = await server.apiClient.responseResponse();
    expect(response, 'Hello, World!');
  });

  test('/response/typed endpoint returns correct data', () async {
    final response = await server.apiClient.responseTypedResponse();
    expect(response, 'Hello, World!');
  });
}
