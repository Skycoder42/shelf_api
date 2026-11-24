import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class EndpointPathParameter({
  required final String name,
  required final OpaqueType type,
  required final bool isString,
  required final bool isEnum,
  required final bool isDateTime,
  required final OpaqueConstant? customParse,
  required final OpaqueConstant? customToString,
  required final bool urlEncode,
}) {
  String get handlerParamName => '\$path\$$name';
}
