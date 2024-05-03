import 'package:meta/meta.dart';

import 'endpoint_method.dart';
import 'opaque_type.dart';

@internal
@immutable
class Endpoint {
  final OpaqueType endpointType;
  final String name;
  final String? path;
  final List<EndpointMethod> methods;

  const Endpoint({
    required this.endpointType,
    required this.name,
    required this.path,
    required this.methods,
  });

  // bool get isAsync => methods.values.any((m) => m.isAsync);
}
