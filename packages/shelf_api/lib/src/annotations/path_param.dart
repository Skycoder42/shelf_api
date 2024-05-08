// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Can be used to add metadata to a path parameter of an endpoint method.
@Target({TargetKind.parameter})
class PathParam {
  /// A custom parse function.
  ///
  /// By default, types of path parameters are automatically parsed. However,
  /// for custom types this means they have to provide a `parse` constructor
  /// or static method. In case you cannot add such a constructor, you can use
  /// any static or top level method with the following signature:
  ///
  /// ```dart
  /// T Function(String)
  /// ```
  final Function? parse;

  /// A custom toString function.
  ///
  /// By default, path parameters are converted to a string via their
  /// [Object.toString] implementation. In case you cannot override the toString
  /// method, you can use any static or top level method with the following
  /// signature:
  ///
  /// ```dart
  /// String Function(T)
  /// ```
  final Function? stringify;

  /// Constructor.
  const PathParam({
    this.parse,
    this.stringify,
  });
}
