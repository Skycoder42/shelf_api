import 'package:meta/meta.dart';

import 'endpoint_body.dart';
import 'endpoint_query_parameter.dart';
import 'endpoint_response_type.dart';

@internal
@immutable
class EndpointMethod {
  final String name;
  final EndpointResponse response;
  final EndpointBody? body;
  final List<EndpointQueryParameter> queryParameters;

  const EndpointMethod({
    required this.name,
    required this.response,
    required this.body,
    required this.queryParameters,
  });
}
