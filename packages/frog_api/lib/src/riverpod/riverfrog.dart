import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'endpoint_ref.dart';

/// A middleware to make riverpod available for route handlers.
///
/// To obtain an [EndpointRef], which must be used to actually access the
/// [ProviderContainer], you can simply use the
/// [RequestContextRiverfrogExtension.ref] extension: `context.ref`
///
/// The
Middleware riverfrog({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) =>
    RiverfrogMiddleware(
      parent: parent,
      overrides: overrides,
      observers: observers,
    ).call;

/// An extension on [RequestContext] to access the [EndpointRef].
extension RequestContextRiverfrogExtension on RequestContext {
  /// Returns the associated [EndpointRef].
  ///
  /// Only works if the [riverfrog] middleware is available in this context.
  EndpointRef get ref => read<EndpointRef>();
}

@internal
@visibleForTesting
class RiverfrogMiddleware {
  final ProviderContainer _providerContainer;

  RiverfrogMiddleware({
    ProviderContainer? parent,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) : _providerContainer = ProviderContainer(
          parent: parent,
          overrides: overrides,
          observers: observers,
        );

  Handler call(Handler next) => (context) async {
        final container = ProviderContainer(
          parent: _providerContainer,
          overrides: [
            requestContextProvider.overrideWithValue(context),
          ],
        );
        final endpointRef = EndpointRef(container);

        try {
          final containerContext =
              context.provide<EndpointRef>(() => endpointRef);
          return await next(containerContext);
        } finally {
          endpointRef.dispose();
          container.dispose();
        }
      };
}
