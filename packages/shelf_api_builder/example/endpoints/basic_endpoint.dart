import 'dart:io';

import 'package:shelf_api/shelf_api.dart';

import '../basic_model.dart';

@ApiEndpoint('/basic')
class BasicEndpoint extends ShelfEndpoint {
  BasicEndpoint(super.request);

  @Get('/')
  String get() => 'Hello, World!';

  @Post(r'/complex/<id|\d+>')
  Future<TResponse<BasicModel>> complexExample(
    int id,
    @BodyParam(fromJson: BasicModel.fromJsonX, toJson: BasicModel.toJsonX)
    BasicModel data, {
    required int factor,
    double delta = 0.5,
    String? extra,
  }) async => TResponse(
    HttpStatus.created,
    body: BasicModel((data.value * factor + delta).round()),
    headers: {HttpHeaders.locationHeader: '/examples/$id', 'X-Extra': ?extra},
  );
}
