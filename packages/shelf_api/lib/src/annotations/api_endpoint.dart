// coverage:ignore-file

import 'package:meta/meta_meta.dart';
import 'package:shelf/shelf.dart';

import 'shelf_api.dart';

/// Marks the given method as a specific endpoint method.
@Target({TargetKind.classType})
class ApiEndpoint {
  /// The base path for all API methods of this endpoint.
  ///
  /// All methods of this endpoint are mounted below [path], except if the
  /// [path] is `'/'`, then they will be mounted directly on the main api
  /// router. [path] must always start with a slash and may or may not end with
  /// one. See routing table below for how this makes a difference.
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

  /// Optional middleware to be applied to this endpoint.
  ///
  /// If specified, this function must return a [Middleware], which is applied
  /// to all requests to this endpoint. If the [ShelfApi.middleware] is also
  /// set, then that middleware will be applied *before* this one.
  ///
  /// **Note:** When specifying a middleware, the [path] must not be just `'/'`,
  /// as setting a middleware for a root-mounted endpoint is not supported.
  final Middleware Function()? middleware;

  /// Constructor.
  const ApiEndpoint(this.path, {this.middleware});
}
