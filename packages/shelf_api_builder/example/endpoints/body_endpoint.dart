import 'dart:typed_data';

import 'package:shelf_api/shelf_api.dart';

import '../basic_model.dart';

@ApiEndpoint('/body')
class BodyEndpoint extends ShelfEndpoint {
  BodyEndpoint(super.request);

  @Get('/text')
  String getText(@bodyParam String body) => body;

  @Get('/text/custom')
  String getTextCustom(@BodyParam(contentTypes: ['text/xml']) String body) =>
      body;

  @Get('/binary')
  Uint8List getBinary(@bodyParam Uint8List body) => body;

  @Get('/stream/text')
  Stream<String> streamText(@bodyParam Stream<String> body) => body;

  @Get('/stream/binary')
  Stream<List<int>> streamBinary(@bodyParam Stream<Uint8List> body) => body;

  @Get('/json')
  BasicModel getJson(@bodyParam BasicModel body) => body;

  @Get('/json/list')
  List<int> getJsonList(@bodyParam List<int> body) => body;

  @Get('/json/map')
  Map<String, BasicModel> getJsonMap(@bodyParam Map<String, BasicModel> body) =>
      body;

  @Get('/json/custom')
  BasicModel getJsonCustom(
    @BodyParam(
      contentTypes: ['application/x-json'],
      fromJson: BasicModel.fromJsonX,
      toJson: BasicModel.toJsonX,
    )
    BasicModel body,
  ) => body;

  @Get('/json/null')
  int? getJsonNull(@bodyParam int? body) => body;

  @Get('/json/null/list')
  List<BasicModel>? getJsonNullList(@bodyParam List<BasicModel>? body) => body;

  @Get('/json/null/map')
  Map<String, int>? getJsonNullMap(@bodyParam Map<String, int>? body) => body;

  @Get('/json/null/custom')
  BasicModel? getJsonNullCustom(
    @BodyParam(
      contentTypes: [],
      fromJson: BasicModel.fromJsonX,
      toJson: BasicModel.toJsonX,
    )
    BasicModel? body,
  ) => body;
}
