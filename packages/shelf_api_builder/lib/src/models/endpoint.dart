import 'package:shelf_api/shelf_api.dart';
import 'package:meta/meta.dart';

import 'endpoint_method.dart';
import 'endpoint_path_parameter.dart';
import 'opaque_type.dart';

@internal
@immutable
class Endpoint {
  final OpaqueType endpointType;
  final String name;
  final List<EndpointPathParameter> pathParameters;
  final Map<HttpMethod, EndpointMethod> methods;

  const Endpoint({
    required this.endpointType,
    required this.pathParameters,
    required this.name,
    required this.methods,
  });

  bool get isAsync => methods.values.any((m) => m.isAsync);
}
