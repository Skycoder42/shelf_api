import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class EndpointPathParameter {
  final String name;
  final OpaqueType type;
  final bool isString;
  final bool isDateTime;
  final OpaqueConstant? customParse;
  final OpaqueConstant? customToString;

  EndpointPathParameter({
    required this.name,
    required this.type,
    required this.isString,
    required this.isDateTime,
    required this.customParse,
    required this.customToString,
  });

  String get handlerParamName => '\$path\$$name';
}
