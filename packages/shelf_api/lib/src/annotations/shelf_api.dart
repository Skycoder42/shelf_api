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

  /// Whether to automatically add a 404 Not Found response for API calls that
  /// return null.
  ///
  /// If enabled, the response mapping will convert `null` responses into a
  /// not found HTTP response. If disabled (the default), a OK response with
  /// the JSON body `null` will be returned instead.
  final bool autoNotFound;

  /// Optional middleware to be applied to the API.
  ///
  /// If specified, this function must return a [Middleware], which is applied
  /// to all requests to this API.
  ///
  /// To set a middleware for a specific endpoint, use [ApiEndpoint.middleware].
  final Middleware Function()? middleware;

  /// Constructor
  const new(
    this.endpoints, {
    this.basePath,
    this.middleware,
    this.autoNotFound = false,
  });
}
