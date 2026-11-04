// coverage:ignore-file
/// @docImport 'shelf_api.dart';
library;

import 'package:meta/meta_meta.dart';

import '../api/http_method.dart';
import 'shelf_api.dart' show ShelfApi;

/// Marks the given method as a specific endpoint method.
@Target({TargetKind.method})
class const ApiMethod(
  /// The HTTP method this method will be called for.
  final String method,

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
  final String path, {

  /// Whether to automatically add a 404 Not Found response for API calls that
  /// return null.
  ///
  /// If enabled, the response mapping will convert `null` responses into a
  /// not found HTTP response. If disabled (the default), a OK response with
  /// the JSON body `null` will be returned instead.
  ///
  /// If unset, the value from the [ShelfApi.autoNotFound] annotation will be
  /// used as a default.
  final bool? autoNotFound,

  /// Custom deserialization function for the response.
  ///
  /// You can use this in case the response type does not have a fromJson
  /// constructor or you need to customize the default deserialization behavior
  /// for it. It must have the following signature:
  ///
  /// ```dart
  /// T Function(dynamic)
  /// ```
  final Function? fromJson,

  /// Custom serialization function for the response.
  ///
  /// You can use this in case the response type does not have a toJson method
  /// or you need to customize the default serialization behavior for it. It
  /// must have the following signature:
  ///
  /// ```dart
  /// dynamic Function(T)
  /// ```
  final Function? toJson,
}) {
  /// Constructor.
  this;
}

/// Marks the given method as a get endpoint method.
@Target({TargetKind.method})
class const Get(String path, {super.autoNotFound, super.fromJson, super.toJson})
    extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.get, path);
}

/// Marks the given method as a delete endpoint method.
@Target({TargetKind.method})
class const Delete(
  String path, {
  super.autoNotFound,
  super.fromJson,
  super.toJson,
}) extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.delete, path);
}

/// Marks the given method as a head endpoint method.
@Target({TargetKind.method})
class const Head(
  String path, {
  super.autoNotFound,
  super.fromJson,
  super.toJson,
}) extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.head, path);
}

/// Marks the given method as a options endpoint method.
@Target({TargetKind.method})
class const Options(
  String path, {
  super.autoNotFound,
  super.fromJson,
  super.toJson,
}) extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.options, path);
}

/// Marks the given method as a patch endpoint method.
@Target({TargetKind.method})
class const Patch(
  String path, {
  super.autoNotFound,
  super.fromJson,
  super.toJson,
}) extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.patch, path);
}

/// Marks the given method as a post endpoint method.
@Target({TargetKind.method})
class const Post(
  String path, {
  super.autoNotFound,
  super.fromJson,
  super.toJson,
}) extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.post, path);
}

/// Marks the given method as a put endpoint method.
@Target({TargetKind.method})
class const Put(String path, {super.autoNotFound, super.fromJson, super.toJson})
    extends ApiMethod {
  /// Constructor.
  this : super(HttpMethod.put, path);
}
