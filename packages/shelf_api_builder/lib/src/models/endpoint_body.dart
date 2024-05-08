import 'package:meta/meta.dart';

import 'opaque_type.dart';
import 'serializable_type.dart';

@internal
enum EndpointBodyType {
  text,
  binary,
  textStream,
  binaryStream,
  json;

  bool get isStream => switch (this) {
        EndpointBodyType.textStream || EndpointBodyType.binaryStream => true,
        _ => false,
      };
}

@internal
class EndpointBody {
  final OpaqueType paramType;
  final EndpointBodyType bodyType;

  EndpointBody({
    required this.paramType,
    required this.bodyType,
  }) {
    if (bodyType == EndpointBodyType.json &&
        paramType is! OpaqueSerializableType) {
      throw ArgumentError(
        'If bodyType is json, paramType must be as $SerializableType',
      );
    }
  }

  bool get isAsync => !bodyType.isStream;

  SerializableType get serializableParamType {
    if (bodyType != EndpointBodyType.json) {
      throw StateError(
        'Cannot get serializableParamType if bodyType is not json',
      );
    }

    return paramType.toSerializable(
      'EndpointBody with bodyType json must hold a OpaqueSerializableType',
    );
  }
}
