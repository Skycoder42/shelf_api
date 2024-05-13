import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart';

import 'endpoint_ref.dart';

/// A key to get the original [EndpointRef] from [Request.context].
///
/// Can only be used if the response was created by the
/// [rivershelf] middleware.
const rivershelfRefKey = 'rivershelf.ref';

/// A middleware to make riverpod available for route handlers.
///
/// To obtain an [EndpointRef], which must be used to actually access the
/// [ProviderContainer], you can simply use the
/// [RequestRivershelfExtension.ref] extension: `context.ref`
Middleware rivershelf({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) =>
    _RivershelfMiddleware(
      parent: parent,
      overrides: overrides,
      observers: observers,
    ).call;

/// An extension on [Request] to access the [EndpointRef].
extension RequestRivershelfExtension on Request {
  /// Returns the associated [EndpointRef].
  ///
  /// Only works if the [rivershelf] middleware is available in this context.
  EndpointRef get ref {
    assert(
      context[rivershelfRefKey] is EndpointRef,
      'Cannot use request.ref without registering the rivershelf '
      'middleware first!',
    );
    return context[rivershelfRefKey]! as EndpointRef;
  }
}

class _RivershelfMiddleware {
  final ProviderContainer _providerContainer;

  _RivershelfMiddleware({
    ProviderContainer? parent,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) : _providerContainer = ProviderContainer(
          parent: parent,
          overrides: overrides,
          observers: observers,
        );

  Handler call(Handler next) => (request) async {
        final container = ProviderContainer(
          parent: _providerContainer,
          overrides: [
            shelfRequestProvider.overrideWithValue(request),
          ],
        );
        final endpointRef = EndpointRef(container);

        try {
          final changedRequest = request.change(
            context: {
              ...request.context,
              rivershelfRefKey: endpointRef,
            },
          );
          return await next(changedRequest);
        } finally {
          endpointRef.dispose();
          container.dispose();
        }
      };
}
