import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class EndpointQueryParameter({
  required final String paramName,
  required final String queryName,
  required final OpaqueType type,
  required final bool isString,
  required final bool isEnum,
  required final bool isDateTime,
  required final bool isList,
  required final bool isOptional,
  required final String? defaultValue,
  required final OpaqueConstant? customParse,
  required final OpaqueConstant? customToString,
}) {
  this {
    if (isList && isOptional && defaultValue == null) {
      throw StateError('Optional list params cannot be nullable!');
    }
  }

  String get handlerParamName => '\$query\$$paramName';
}
