// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Annotation to mark a route endpoint as such.
@Target({TargetKind.classType})
class ShelfApiEndpoint {
  /// Configuration for the types of the routes path parameters.
  final Map<Symbol, Type> pathParams;

  /// Constructor
  const ShelfApiEndpoint({
    this.pathParams = const {},
  });
}
