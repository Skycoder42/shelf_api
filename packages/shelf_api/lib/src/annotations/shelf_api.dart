// coverage:ignore-file

import 'package:meta/meta_meta.dart';
import 'package:shelf/shelf.dart';

import 'api_endpoint.dart';

/// Annotation to mark a class as shelf API router
@Target({TargetKind.classType})
class ShelfApi {
  /// The list of endpoint classes the API is composed of
  final List<Type> endpoints;

  /// The base API path to prepend to each API route.
  ///
  /// If left empty, no prefix is added.
  final String? basePath;

  /// Optional middleware to be applied to the API.
  ///
  /// If specified, this function must return a [Middleware], which is applied
  /// to all requests to this API.
  ///
  /// To set a middleware for a specific endpoint, use [ApiEndpoint.middleware].
  final Middleware Function()? middleware;

  /// Constructor
  const ShelfApi(
    this.endpoints, {
    this.basePath,
    this.middleware,
  });
}
