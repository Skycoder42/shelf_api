import 'package:meta/meta.dart';

import 'opaque_constant.dart';
import 'opaque_type.dart';

@internal
enum Wrapped {
  none,
  list,
  map;
}

@internal
@immutable
class SerializableType {
  final OpaqueType dartType;
  final Wrapped wrapped;
  final bool isNullable;
  final OpaqueType? jsonType;
  final OpaqueConstant? fromJson;
  final OpaqueConstant? toJson;

  const SerializableType({
    required this.dartType,
    required this.wrapped,
    required this.isNullable,
    required this.jsonType,
    this.fromJson,
    this.toJson,
  }) : assert(
          wrapped == Wrapped.none || (fromJson == null && toJson == null),
          'If fromJson or toJson are set, wrapped must be Wrapped.none!',
        );
}
