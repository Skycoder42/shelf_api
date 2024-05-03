import 'package:shelf_api/shelf_api.dart';

class BasicModel {
  // ignore: avoid_unused_constructor_parameters
  BasicModel.fromJson(Map<String, int> t);

  // ignore: prefer_constructors_over_static_methods
  static BasicModel fromJsonX(dynamic j) =>
      BasicModel.fromJson(j as Map<String, int>);
}

@ApiEndpoint('/basic')
class BasicEndpoint extends ShelfEndpoint {
  BasicEndpoint(super.request);

  @Get('/params')
  String get() => 'Hello, World!';

  // @Get('/params')
  // String get({
  //   required String sValue,
  //   int? oValue,
  //   double dValue = 42.0,
  //   required Uri uValue,
  //   DateTime? dtValue,
  //   String s2Value = 's2',
  // }) =>
  //     'Hello, World!';

  // @Post('/', bodyFromJson: BasicModel.fromJsonX)
  // void post(BasicModel value) {}
}
