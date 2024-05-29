import 'package:meta/meta.dart';

import 'endpoint.dart';
import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
class ApiClass {
  final OpaqueType classType;
  final String className;
  final List<Endpoint> endpoints;
  final String? basePath;
  final OpaqueConstant? middleware;

  ApiClass({
    required this.classType,
    required this.className,
    required this.endpoints,
    required this.basePath,
    required this.middleware,
  });

  String get implementationName => className.substring(1);

  String get clientName => '${implementationName}Client';
}
