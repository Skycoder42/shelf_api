import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

import '../annotations/shelf_api.dart';
import '../riverpod/endpoint_ref.dart';
import '../riverpod/rivershelf.dart';

/// The base class for all shelf API endpoints.
///
/// See [ShelfApi] for how to register these endpoints.
abstract class ShelfEndpoint {
  /// The original request being processed by this endpoint.
  final Request request;

  /// The [EndpointRef] attached to the [request]
  final EndpointRef ref;

  /// Default constructor.
  ///
  /// The [ref] parameter is optional and only made visible for testing purpose.
  ShelfEndpoint(
    this.request, {
    @visibleForTesting EndpointRef? ref,
  }) : ref = ref ?? request.ref;

  /// Endpoint initializer callback.
  ///
  /// Is called by the framework before the actual handler method gets invoked.
  /// You can use this method to execute code before every request that will
  /// be served by this handler.
  ///
  /// See [dispose] for a cleanup callback.
  @protected
  FutureOr<void> init() {}

  /// Endpoint finalizer callback.
  ///
  /// Is called by the framework after the actual handler method was invoked.
  /// You can use this method to execute code after every request that will
  /// be served by this handler.
  ///
  /// **Important:** When returning [Stream] results from a handler, this method
  /// will be invoked *before* the stream gets consumed! Do not use it for
  /// cleanup logic that should run after a streams consumption.
  ///
  /// See [init] for a setup callback.
  @protected
  FutureOr<void> dispose() {}
}
