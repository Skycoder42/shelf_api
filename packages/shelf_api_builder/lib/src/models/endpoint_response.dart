import 'package:meta/meta.dart';

import 'opaque_type.dart';
import 'serializable_type.dart';

@internal
enum EndpointResponseType {
  noContent,
  text,
  binary,
  textStream,
  binaryStream,
  json,
  dynamic;

  bool get isStream => switch (this) {
    EndpointResponseType.textStream ||
    EndpointResponseType.binaryStream => true,
    _ => false,
  };
}

@internal
class EndpointResponse {
  final EndpointResponseType responseType;
  final OpaqueType returnType;
  final bool isResponse;
  final bool isAsync;
  final bool autoNotFound;

  new({
    required this.responseType,
    required this.returnType,
    this.isResponse = false,
    this.isAsync = false,
    this.autoNotFound = false,
  }) {
    if (responseType == EndpointResponseType.json &&
        returnType is! OpaqueSerializableType) {
      throw ArgumentError(
        'If responseType is json, returnType must be as $SerializableType',
      );
    }
  }

  EndpointResponse copyWith({
    EndpointResponseType? responseType,
    OpaqueType? returnType,
    bool? isResponse,
    bool? isAsync,
  }) => EndpointResponse(
    responseType: responseType ?? this.responseType,
    returnType: returnType ?? this.returnType,
    isResponse: isResponse ?? this.isResponse,
    isAsync: isAsync ?? this.isAsync,
  );

  SerializableType get serializableReturnType {
    if (responseType != EndpointResponseType.json) {
      throw StateError(
        'Cannot get serializableReturnType if responseType is not json',
      );
    }
    return returnType.toSerializable(
      'EndpointResponse with responseType json must hold a '
      'OpaqueSerializableType',
    );
  }

  bool get autoNotFoundActivated => switch (this) {
    EndpointResponse(
      responseType: .json,
      autoNotFound: true,
      returnType: OpaqueSerializableType(
        serializableType: SerializableType(isNullable: true),
      ),
    ) =>
      true,
    _ => false,
  };
}
