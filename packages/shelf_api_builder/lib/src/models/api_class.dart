import 'package:meta/meta.dart';

import 'endpoint.dart';
import 'opaque_type.dart';

@internal
@immutable
class ApiClass {
  final OpaqueType classType;
  final String className;
  final List<Endpoint> endpoints;

  const ApiClass({
    required this.classType,
    required this.className,
    required this.endpoints,
  });

  String get mixinName => '_\$$className';

  String get implementationName => '_$className';
}
