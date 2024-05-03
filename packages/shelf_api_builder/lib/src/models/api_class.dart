import 'package:meta/meta.dart';

import 'endpoint.dart';
import 'opaque_type.dart';

@internal
@immutable
class ApiClass {
  final OpaqueType classType;
  final String className;
  final List<Endpoint> endpoints;
  final String? basePath;

  const ApiClass({
    required this.classType,
    required this.className,
    required this.endpoints,
    required this.basePath,
  });

  String get implementationName => className.substring(1);

  String get clientName => '${implementationName}Client';
}
