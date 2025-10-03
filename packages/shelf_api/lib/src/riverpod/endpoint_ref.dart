import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';

part 'endpoint_ref.g.dart';

/// A provider to access a requests [Request] within a provider.
///
/// **Important:** This provider must be added as a dependency, as it will
/// cause dependant providers to the valid only for the request itself. This
/// means providers depending on [shelfRequestProvider] will be unique per
/// request instead of being a global singleton.
///
/// This can also be used to create request unique providers, even if the
/// [Request] itself is not being used:
///
/// ```dart
/// @Riverpod(dependencies: [shelfRequestProvider])
/// MyValue myValue(MyValueRef ref) => MyValue(ref);
/// ```
@Riverpod(keepAlive: true, dependencies: [])
Request shelfRequest(Ref ref) => throw StateError(
  'shelfRequestProvider can only be accessed via session.ref',
);

/// An object that allows shelf request handlers to interact with providers.
class EndpointRef {
  /// @nodoc
  @internal
  final ProviderContainer container;

  final _keepAliveSubs = <ProviderListenable<dynamic>, ProviderSubscription>{};

  /// @nodoc
  @internal
  EndpointRef(this.container);

  /// Determines whether a provider is initialized or not.
  ///
  /// See [Ref.exists] for more details.
  bool exists(ProviderBase<Object?> provider) => container.exists(provider);

  /// Reads a provider without listening to it.
  ///
  /// Works just like [Ref.read], but with one minor difference: If the provider
  /// is a auto disposable provider, it will not be disposed until the request
  /// itself is finished. Internally, [Ref.listen] is used to archive this.
  ///
  /// See [Ref.read] and [Ref.watch] for more details.
  T read<T>(ProviderListenable<T> provider) {
    final subscription =
        _keepAliveSubs.putIfAbsent(
              provider,
              () => container.listen(provider, (_, _) {}),
            )
            as ProviderSubscription<T>;
    return subscription.read();
  }

  /// Forces a provider to re-evaluate its state immediately, and return the
  /// created value.
  ///
  /// See [Ref.refresh] for more details.
  @useResult
  State refresh<State>(Refreshable<State> provider) =>
      container.refresh(provider);

  /// Invalidates the state of the provider, causing it to refresh.
  ///
  /// See [Ref.invalidate] for more details.
  void invalidate(ProviderOrFamily provider) => container.invalidate(provider);

  /// @nodoc
  @internal
  void dispose() {
    for (final subscription in _keepAliveSubs.values) {
      subscription.close();
    }
  }
}
