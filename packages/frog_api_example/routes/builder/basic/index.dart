import 'package:frog_api/frog_api.dart';

part 'index.g.dart';

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

  void post(String value) {}
}
