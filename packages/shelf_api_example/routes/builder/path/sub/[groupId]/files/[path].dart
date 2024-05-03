// ignore_for_file: type_init_formals, file_names

import 'package:shelf_api/shelf_api.dart';

part '[path].api.dart';

@FrogEndpoint()
final class NestedParamEndpoint extends _$NestedParamEndpoint {
  NestedParamEndpoint(super.context, super.groupId, super.path);

  String get() => '';
}
