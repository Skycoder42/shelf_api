// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Converter function to create an instance of T from json data
typedef BodyFromJson<T extends Object> = T Function(dynamic json);

/// Annotation to mark a route endpoint as such.
@Target({TargetKind.classType})
class FrogEndpoint {
  /// Configuration for the types of the routes path parameters.
  final Map<Symbol, Type> pathParams;

  /// Custom converter function for the body.
  ///
  /// You can use this in case the body type does not have a fromJson
  /// constructor or you need to customize the default deserialization behavior
  /// for it.
  final BodyFromJson? bodyFromJson;

  /// Constructor
  const FrogEndpoint({
    this.pathParams = const {},
    this.bodyFromJson,
  });
}
