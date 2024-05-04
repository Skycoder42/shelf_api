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
  json;

  bool get isStream => switch (this) {
        EndpointResponseType.textStream ||
        EndpointResponseType.binaryStream =>
          true,
        _ => false,
      };
}

@internal
@immutable
class EndpointResponse {
  final EndpointResponseType responseType;
  final OpaqueType rawType;
  final bool isResponse;
  final bool isAsync;
  final OpaqueConstant? toJson;

  const EndpointResponse({
    required this.responseType,
    required this.rawType,
    this.isResponse = false,
    this.isAsync = false,
    this.toJson,
  });

  EndpointResponse copyWith({
    EndpointResponseType? responseType,
    OpaqueType? rawType,
    bool? isResponse,
    bool? isAsync,
    OpaqueConstant? toJson,
  }) =>
      EndpointResponse(
        responseType: responseType ?? this.responseType,
        rawType: rawType ?? this.rawType,
        isResponse: isResponse ?? this.isResponse,
        isAsync: isAsync ?? this.isAsync,
        toJson: toJson ?? toJson,
      );
}
