// coverage:ignore-file

import 'package:meta/meta_meta.dart';

import '../api/http_method.dart';

/// Marks the given method as a specific endpoint method.
@Target({TargetKind.method})
class ApiMethod {
  /// The HTTP method this method will be called for.
  final String method;

  /// The path to this API method.
  ///
  /// [path] must always start with a slash and may or may not end with one.
  /// See routing table below for how this makes a difference.
  ///
  /// Example Routing Table:
  ///  Endpoint Route | Method Route | Resolves to
  /// ----------------|--------------|-------
  ///  *none*         | /            | /
  ///  *none*         | /users       | /users
  ///  *none*         | /users/      | /users/
  ///  /              | /            | /
  ///  /              | /users       | /users
  ///  /              | /users/      | /users/
  ///  /api           | /            | /api *or* /api/
  ///  /api           | /users       | /api/users
  ///  /api           | /users/      | /api/users/
  ///  /api/          | /            | /api/
  ///  /api/          | /users       | /api/users
  ///  /api/          | /users/      | /api/users/
  final String path;

  /// Custom converter function for the response.
  ///
  /// You can use this in case the response type does not have a toJson method
  /// or you need to customize the default serialization behavior for it.
  final Function? toJson;

  /// Constructor.
  const ApiMethod(
    this.method,
    this.path, {
    this.toJson,
  });
}

/// Marks the given method as a get endpoint method.
@Target({TargetKind.method})
class Get extends ApiMethod {
  /// Constructor.
  const Get(String path, {super.toJson}) : super(HttpMethod.get, path);
}

/// Marks the given method as a delete endpoint method.
@Target({TargetKind.method})
class Delete extends ApiMethod {
  /// Constructor.
  const Delete(String path, {super.toJson}) : super(HttpMethod.delete, path);
}

/// Marks the given method as a head endpoint method.
@Target({TargetKind.method})
class Head extends ApiMethod {
  /// Constructor.
  const Head(String path, {super.toJson}) : super(HttpMethod.head, path);
}

/// Marks the given method as a options endpoint method.
@Target({TargetKind.method})
class Options extends ApiMethod {
  /// Constructor.
  const Options(String path, {super.toJson}) : super(HttpMethod.options, path);
}

/// Marks the given method as a patch endpoint method.
@Target({TargetKind.method})
class Patch extends ApiMethod {
  /// Constructor.
  const Patch(String path, {super.toJson}) : super(HttpMethod.patch, path);
}

/// Marks the given method as a post endpoint method.
@Target({TargetKind.method})
class Post extends ApiMethod {
  /// Constructor.
  const Post(String path, {super.toJson}) : super(HttpMethod.post, path);
}

/// Marks the given method as a put endpoint method.
@Target({TargetKind.method})
class Put extends ApiMethod {
  /// Constructor.
  const Put(String path, {super.toJson}) : super(HttpMethod.put, path);
}
