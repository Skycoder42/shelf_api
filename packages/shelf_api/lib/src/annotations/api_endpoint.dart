// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Marks the given method as a specific endpoint method.
@Target({TargetKind.classType})
class ApiEndpoint {
  /// The base path for all API methods of this endpoint.
  ///
  /// When set, all methods of this endpoint are mounted below [path]. Otherwise
  /// they will be mounted directly on the main api router. [path] must always
  /// start with a slash and may or may not end with one. See routing table
  /// below for how this makes a difference.
  ///
  /// Example Routing Table:
  ///  Endpoint Route | Method Route | Resolves to
  /// ----------------|--------------|-------
  ///  *none*         | /            | /
  ///  *none*         | /users       | /users
  ///  *none*         | /users/      | /users/
  ///  /              | /            | /
  ///  /              | /users       | /users
  ///  /              | /users/      | /users/
  ///  /api           | /            | /api *or* /api/
  ///  /api           | /users       | /api/users
  ///  /api           | /users/      | /api/users/
  ///  /api/          | /            | /api/
  ///  /api/          | /users       | /api/users
  ///  /api/          | /users/      | /api/users/
  final String path;

  /// Constructor.
  const ApiEndpoint(this.path);
}
