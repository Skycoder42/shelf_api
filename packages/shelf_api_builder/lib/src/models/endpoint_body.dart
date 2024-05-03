import 'package:meta/meta.dart';

import 'opaque_type.dart';

@internal
enum EndpointBodyType {
  text,
  binary,
  textStream,
  binaryStream,
  json,
  jsonList,
  jsonMap;

  bool get isStream => switch (this) {
        EndpointBodyType.textStream || EndpointBodyType.binaryStream => true,
        _ => false,
      };
}

@internal
@immutable
class EndpointBody {
  final OpaqueType paramType;
  final EndpointBodyType bodyType;
  final bool isNullable;
  final OpaqueType? jsonType;
  final String? fromJson;

  const EndpointBody({
    required this.paramType,
    required this.bodyType,
    this.isNullable = false,
    this.jsonType,
    this.fromJson,
  });

  bool get isAsync => !bodyType.isStream;
}
