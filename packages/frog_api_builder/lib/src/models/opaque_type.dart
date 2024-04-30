import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

@internal
@immutable
sealed class OpaqueType {
  const OpaqueType();
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
