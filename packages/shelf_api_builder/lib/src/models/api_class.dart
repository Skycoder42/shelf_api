import 'package:meta/meta.dart';

import 'endpoint.dart';
import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
class ApiClass({
  required final OpaqueType classType,
  required final String className,
  required final List<Endpoint> endpoints,
  required final String? basePath,
  required final OpaqueConstant? middleware,
}) {
  String get implementationName => className.substring(1);

  String get clientName => '${implementationName}Client';
}
