import 'package:meta/meta.dart';

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

  const EndpointResponse({
    required this.responseType,
    this.isAsync = false,
  });

  EndpointResponse copyWith({
    EndpointResponseType? responseType,
    bool? isAsync,
  }) =>
      EndpointResponse(
        responseType: responseType ?? this.responseType,
        isAsync: isAsync ?? this.isAsync,
      );
}
