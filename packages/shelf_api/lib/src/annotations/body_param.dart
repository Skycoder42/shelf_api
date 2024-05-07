// coverage:ignore-file

import 'package:meta/meta_meta.dart';

/// Marks the given parameter as the body of the request.
@Target({TargetKind.parameter})
class BodyParam {
  /// Custom deserialization function for the body.
  ///
  /// You can use this in case the body type does not have a fromJson
  /// constructor or you need to customize the default deserialization behavior
  /// for it.
  final Function? fromJson;

  /// Custom serialization function for the body.
  ///
  /// You can use this in case the body type does not have a toJson method
  /// or you need to customize the default serialization behavior for it.
  final Function? toJson;

  /// Constructor.
  const BodyParam({
    this.fromJson,
    this.toJson,
  });
}

/// Marks the given parameter as the body of the request.
const bodyParam = BodyParam();
