import 'dart:typed_data';

import 'package:shelf_api/shelf_api.dart';

import '../basic_model.dart';

@ApiEndpoint('/response/')
class ResponseEndpoint extends ShelfEndpoint {
  ResponseEndpoint(super.request);

  @Get('/noContent')
  void noContent() {}

  @Get('/text')
  String text() => 'Hello, World!';

  @Get('/binary')
  Uint8List binary() => Uint8List.fromList([1, 2, 3, 4, 5]);

  @Get('/json')
  BasicModel json() => const BasicModel(42);

  @Get('/json/list')
  List<int> jsonList() => const [1, 2, 3];

  @Get('/json/map')
  Map<String, BasicModel> jsonMap() => const {'a': BasicModel(1)};

  @Get('/json/custom', toJson: BasicModel.toJsonX)
  BasicModel jsonCustom() => const BasicModel(42);

  @Get('/response')
  Response response() => Response.ok('Hello, World!');

  @Get('/response/typed')
  TResponse<String> typedResponse() => TResponse.ok('Hello, World!');

  @Get('/async/noContent')
  Future<void> asyncNoContent() async {}

  @Get('/async/text')
  Future<String> asyncText() async => 'Hello, World!';

  @Get('/async/binary')
  Future<Uint8List> asyncBinary() async => Uint8List.fromList([1, 2, 3, 4, 5]);

  @Get('/async/json')
  Future<BasicModel> asyncJson() async => const BasicModel(42);

  @Get('/async/json/list')
  Future<List<int>> asyncJsonList() async => const [1, 2, 3];

  @Get('/async/json/map')
  Future<Map<String, BasicModel>> asyncJsonMap() async =>
      const {'a': BasicModel(1)};

  @Get('/async/json/custom', toJson: BasicModel.toJsonX)
  Future<BasicModel> asyncJsonCustom() async => const BasicModel(42);

  @Get('/async/response')
  Future<Response> asyncResponse() async => Response.ok('Hello, World!');

  @Get('/async/response/typed')
  Future<TResponse<String>> asyncTypedResponse() async =>
      TResponse.ok('Hello, World!');

  @Get('/stream/text')
  Stream<String> streamText() => Stream.value('Hello, World!');

  @Get('/stream/binary')
  Stream<List<int>> streamBinary() => Stream.value([1, 2, 3, 4, 5]);
}
