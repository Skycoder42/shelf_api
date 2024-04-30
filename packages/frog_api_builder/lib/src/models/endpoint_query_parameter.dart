import 'package:meta/meta.dart';

import 'opaque_type.dart';

@internal
@immutable
class EndpointQueryParameter {
  final String name;
  final OpaqueType type;
  final bool isString;
  final bool isOptional;
  final String? defaultValue;

  const EndpointQueryParameter({
    required this.name,
    required this.type,
    required this.isString,
    this.isOptional = false,
    this.defaultValue,
  });
}
