// ignore_for_file: type_init_formals, file_names

import 'package:frog_api/frog_api.dart';

part '[id].api.dart';

@FrogEndpoint()
final class SimpleParamEndpoint extends _$SimpleParamEndpoint {
  SimpleParamEndpoint(super.context, super.id);

  String get() => '';
}
