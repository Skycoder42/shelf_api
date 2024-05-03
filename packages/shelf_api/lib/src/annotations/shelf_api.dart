// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Annotation to mark a class as shelf API router
@Target({TargetKind.classType})
class ShelfApi {
  /// The list of endpoint classes the API is composed of
  final List<Type> endpoints;

  /// The base API path to prepend to each API route.
  ///
  /// If left empty, no prefix is added.
  final String? basePath;

  /// Constructor
  const ShelfApi(
    this.endpoints, {
    this.basePath,
  });
}
