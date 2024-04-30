// coverage:ignore-file

import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta_meta.dart';

/// Marks the given method as a specific endpoint method
@Target({TargetKind.method})
class FrogMethod {
  /// The HTTP method this method will be called for.
  final HttpMethod method;

  /// Constructor.
  const FrogMethod(this.method);
}

/// Marks the given method as the endpoints delete method
const delete = FrogMethod(HttpMethod.delete);

/// Marks the given method as the endpoints get method
const get = FrogMethod(HttpMethod.get);

/// Marks the given method as the endpoints head method
const head = FrogMethod(HttpMethod.head);

/// Marks the given method as the endpoints options method
const options = FrogMethod(HttpMethod.options);

/// Marks the given method as the endpoints patch method
const patch = FrogMethod(HttpMethod.patch);

/// Marks the given method as the endpoints post method
const post = FrogMethod(HttpMethod.post);

/// Marks the given method as the endpoints put method
const put = FrogMethod(HttpMethod.put);
