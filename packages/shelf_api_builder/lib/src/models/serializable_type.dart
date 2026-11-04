import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
enum Wrapped() {
  none,
  list,
  map,
}

@internal
class SerializableType({
  required final OpaqueType dartType,
  required final Wrapped wrapped,
  required final bool isNullable,
  required final OpaqueType? jsonType,
  final OpaqueConstant? fromJson,
  final OpaqueConstant? toJson,
}) {
  this {
    if ((fromJson != null || toJson != null) && wrapped != Wrapped.none) {
      throw ArgumentError(
        'If fromJson or toJson are set, wrapped must be Wrapped.none!',
      );
    }
  }
}
