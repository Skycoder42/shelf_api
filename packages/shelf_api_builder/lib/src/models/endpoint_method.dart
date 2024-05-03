import 'package:meta/meta.dart';

import 'endpoint_response.dart';

@internal
@immutable
class EndpointMethod {
  final String name;
  final String httpMethod;
  final String path;
  final EndpointResponse response;
  // final EndpointBody? body;
  // final List<EndpointQueryParameter> queryParameters;

  const EndpointMethod({
    required this.name,
    required this.httpMethod,
    required this.path,
    required this.response,
    // required this.body,
    // required this.queryParameters,
  });

  bool get isAsync => response.isAsync; //|| (body?.isAsync ?? false);
}
