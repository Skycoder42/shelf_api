import 'package:meta/meta.dart';

import 'endpoint_body.dart';
import 'endpoint_path_parameter.dart';
import 'endpoint_query_parameter.dart';
import 'endpoint_response.dart';

@internal
class EndpointMethod {
  final String name;
  final String httpMethod;
  final String path;
  final EndpointResponse response;
  final EndpointBody? body;
  final List<EndpointPathParameter> pathParameters;
  final List<EndpointQueryParameter> queryParameters;

  EndpointMethod({
    required this.name,
    required this.httpMethod,
    required this.path,
    required this.response,
    required this.body,
    required this.pathParameters,
    required this.queryParameters,
  });

  bool get isAsync => response.isAsync;

  bool get isStream => response.responseType.isStream;
}
