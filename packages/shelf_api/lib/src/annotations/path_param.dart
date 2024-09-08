// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Can be used to add metadata to a path parameter of an endpoint method.
@Target({TargetKind.parameter})
class PathParam {
  /// Specifies whether the path parameter should be URL encoded.
  ///
  /// If enabled, all params are encoded, to ensure special characters (like
  /// '/') do not break path resolution. This means that the client will
  /// automatically encode all path parameters and the server will automatically
  /// decode all parameters.
  ///
  /// When disabled, no encoding or decoding happens, which allows you to for
  /// example use '/' in a path param to actually change the path. However, this
  /// can lead to problems with path matching and should be avoided
  final bool urlEncode;

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
    this.urlEncode = true,
    this.parse,
    this.stringify,
  });
}
