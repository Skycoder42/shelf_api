// coverage:ignore-file

import 'package:meta/meta_meta.dart';

import '../api/http_method.dart';

/// Marks the given method as a specific endpoint method
@Target({TargetKind.method})
class ShelfApiMethod {
  /// The HTTP method this method will be called for.
  final String method;

  /// Custom converter function for the body.
  ///
  /// You can use this in case the body type does not have a fromJson
  /// constructor or you need to customize the default deserialization behavior
  /// for it.
  final Function? bodyFromJson;

  /// Constructor.
  const ShelfApiMethod(
    this.method, {
    this.bodyFromJson,
  });
}

/// Marks the given method as the endpoints connect method
const connect = ShelfApiMethod(HttpMethod.connect);

/// Marks the given method as the endpoints delete method
const delete = ShelfApiMethod(HttpMethod.delete);

/// Marks the given method as the endpoints get method
const get = ShelfApiMethod(HttpMethod.get);

/// Marks the given method as the endpoints head method
const head = ShelfApiMethod(HttpMethod.head);

/// Marks the given method as the endpoints options method
const options = ShelfApiMethod(HttpMethod.options);

/// Marks the given method as the endpoints patch method
const patch = ShelfApiMethod(HttpMethod.patch);

/// Marks the given method as the endpoints post method
const post = ShelfApiMethod(HttpMethod.post);

/// Marks the given method as the endpoints put method
const put = ShelfApiMethod(HttpMethod.put);

/// Marks the given method as the endpoints trace method
const trace = ShelfApiMethod(HttpMethod.trace);
