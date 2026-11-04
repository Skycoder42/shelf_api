import 'package:meta/meta.dart';

import 'endpoint_method.dart';
import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class Endpoint({
  required final OpaqueType endpointType,
  required final String name,
  required final String? path,
  required final List<EndpointMethod> methods,
  required final OpaqueConstant? middleware,
}) {
  this {
    if (middleware != null && (path == null || path == '/')) {
      throw StateError('middleware cannot be set if path is "/" or null');
    }
  }
}
