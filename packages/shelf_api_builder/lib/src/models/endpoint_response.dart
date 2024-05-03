import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
enum EndpointResponseType {
  noContent,
  text,
  binary,
  textStream,
  binaryStream,
  json,
  response,
}

@internal
@immutable
class EndpointResponse {
  final EndpointResponseType responseType;
  final OpaqueType rawType;
  final bool isAsync;
  final OpaqueConstant? toJson;

  const EndpointResponse({
    required this.responseType,
    required this.rawType,
    this.isAsync = false,
    this.toJson,
  });

  EndpointResponse copyWith({
    EndpointResponseType? responseType,
    OpaqueType? rawType,
    bool? isAsync,
    OpaqueConstant? toJson,
  }) =>
      EndpointResponse(
        responseType: responseType ?? this.responseType,
        rawType: rawType ?? this.rawType,
        isAsync: isAsync ?? this.isAsync,
        toJson: toJson ?? toJson,
      );
}
