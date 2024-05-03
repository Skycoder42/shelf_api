import 'package:meta/meta.dart';

import 'opaque_type.dart';

@internal
@immutable
class EndpointQueryParameter {
  final String paramName;
  final String queryName;
  final OpaqueType type;
  final bool isString;
  final bool isList;
  final bool isOptional;
  final String? defaultValue;
  final String? customParse;

  const EndpointQueryParameter({
    required this.paramName,
    required this.queryName,
    required this.type,
    required this.isString,
    required this.isList,
    required this.isOptional,
    required this.defaultValue,
    required this.customParse,
  });
}
