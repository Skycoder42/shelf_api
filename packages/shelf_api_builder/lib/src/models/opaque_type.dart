import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'serializable_type.dart';

@internal
@immutable
sealed class OpaqueType {
  const OpaqueType();

  SerializableType toSerializable(String reason) => switch (this) {
        OpaqueSerializableType(serializableType: final type) => type,
        _ => throw StateError(reason),
      };
}

@internal
@immutable
class OpaqueSerializableType extends OpaqueType {
  final SerializableType serializableType;

  const OpaqueSerializableType(this.serializableType);
}

@internal
@immutable
class OpaqueDartType extends OpaqueType {
  final DartType dartType;

  const OpaqueDartType(this.dartType);
}

@internal
@immutable
class OpaqueClassType extends OpaqueType {
  final ClassElement element;

  const OpaqueClassType(this.element);
}

@internal
@immutable
class OpaqueVoidType extends OpaqueType {
  const OpaqueVoidType();
}
