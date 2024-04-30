import 'package:frog_api/frog_api.dart';

part 'index.g.dart';

class XXX {
  // ignore: avoid_unused_constructor_parameters
  XXX.fromJson(Map<String, int> t);
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

  void post(XXX value) {}
}
