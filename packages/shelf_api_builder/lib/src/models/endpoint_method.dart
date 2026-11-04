import 'package:meta/meta.dart';

import 'endpoint_body.dart';
import 'endpoint_path_parameter.dart';
import 'endpoint_query_parameter.dart';
import 'endpoint_response.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
class EndpointMethod({
  required final String name,
  required final String httpMethod,
  required final String path,
  required final EndpointResponse response,
  required final EndpointBody? body,
  required final List<EndpointPathParameter> pathParameters,
  required final List<EndpointQueryParameter> queryParameters,
}) {
  bool get isAsync => response.isAsync;

  bool get isStream => response.responseType.isStream;
}
