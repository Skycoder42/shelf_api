import 'package:meta/meta.dart';

import 'endpoint_method.dart';
import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class Endpoint {
  final OpaqueType endpointType;
  final String name;
  final String? path;
  final List<EndpointMethod> methods;
  final OpaqueConstant? middleware;

  Endpoint({
    required this.endpointType,
    required this.name,
    required this.path,
    required this.methods,
    required this.middleware,
  }) {
    if (middleware != null && (path == null || path == '/')) {
      throw StateError('middleware cannot be set if path is "/" or null');
    }
  }
}
