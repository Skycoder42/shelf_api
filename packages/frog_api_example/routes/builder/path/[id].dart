import 'package:frog_api/frog_api.dart';

part '[id].api.dart';

@FrogEndpoint()
final class SimpleParamEndpoint extends _$SimpleParamEndpoint {
  SimpleParamEndpoint(super.context);

  String get() => '';
}
