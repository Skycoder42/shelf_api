import 'package:shelf_api/shelf_api.dart';

part 'index.api.dart';

class BasicModel {
  // ignore: avoid_unused_constructor_parameters
  BasicModel.fromJson(Map<String, int> t);

  // ignore: prefer_constructors_over_static_methods
  static BasicModel fromJsonX(dynamic j) =>
      BasicModel.fromJson(j as Map<String, int>);
}

@FrogEndpoint()
final class BasicEndpoint extends _$BasicEndpoint {
  BasicEndpoint(super.context);

  String get({
    required String sValue,
    int? oValue,
    double dValue = 42.0,
    required Uri uValue,
    DateTime? dtValue,
    String s2Value = 's2',
  }) =>
      'Hello, World!';

  @FrogMethod(HttpMethod.post, bodyFromJson: BasicModel.fromJsonX)
  void post(BasicModel value) {}
}
