import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';

import 'endpoint_method.dart';
import 'opaque_type.dart';

@internal
@immutable
class Endpoint {
  final OpaqueType endpointType;
  final String name;
  final Map<HttpMethod, EndpointMethod> methods;

  const Endpoint({
    required this.endpointType,
    required this.name,
    required this.methods,
  });
}
