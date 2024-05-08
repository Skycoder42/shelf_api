import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'serializable_type.dart';

@internal
sealed class OpaqueType {
  OpaqueType();

  SerializableType toSerializable(String reason) => switch (this) {
        OpaqueSerializableType(serializableType: final type) => type,
        _ => throw StateError(reason),
      };
}

@internal
class OpaqueSerializableType extends OpaqueType {
  final SerializableType serializableType;

  OpaqueSerializableType(this.serializableType);
}

@internal
class OpaqueDartType extends OpaqueType {
  final DartType dartType;

  OpaqueDartType(this.dartType);
}

@internal
class OpaqueClassType extends OpaqueType {
  final ClassElement element;

  OpaqueClassType(this.element);
}

@internal
class OpaqueVoidType extends OpaqueType {
  OpaqueVoidType();
}
