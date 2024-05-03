import 'package:meta/meta.dart';

import 'opaque_constant.dart';

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
  final bool isAsync;
  final OpaqueConstant? toJson;

  const EndpointResponse({
    required this.responseType,
    this.isAsync = false,
    this.toJson,
  });

  EndpointResponse copyWith({
    EndpointResponseType? responseType,
    bool? isAsync,
    OpaqueConstant? toJson,
  }) =>
      EndpointResponse(
        responseType: responseType ?? this.responseType,
        isAsync: isAsync ?? this.isAsync,
        toJson: toJson ?? toJson,
      );
}
