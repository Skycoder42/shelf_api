import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
@immutable
class EndpointPathParameter {
  final String name;
  final OpaqueType type;
  final bool isString;
  final OpaqueConstant? customParse;

  const EndpointPathParameter({
    required this.name,
    required this.type,
    required this.isString,
    required this.customParse,
  });
}
