import 'package:meta/meta_meta.dart';

/// Annotation to mark a route endpoint as such.
@Target({TargetKind.classType})
class FrogEndpoint {
  /// Configuration for the types of the routes path parameters.
  final Map<Symbol, Type> pathParams;

  /// Constructor
  const FrogEndpoint({
    this.pathParams = const {},
  });
}
