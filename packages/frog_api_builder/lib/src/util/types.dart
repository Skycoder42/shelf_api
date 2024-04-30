import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../models/opaque_type.dart';

@internal
abstract base class Types {
  Types._();

  static final dynamic$ = TypeReference((b) => b..symbol = 'dynamic');

  static final void$ = TypeReference((b) => b..symbol = 'void');

  static final string = TypeReference((b) => b..symbol = 'String');

  static final TypeReference httpStatus = TypeReference(
    (b) => b
      ..symbol = 'HttpStatus'
      ..url = 'dart:io',
  );

  static final TypeReference httpMethod = TypeReference(
    (b) => b
      ..symbol = 'HttpMethod'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference requestContext = TypeReference(
    (b) => b
      ..symbol = 'RequestContext'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference request = TypeReference(
    (b) => b
      ..symbol = 'Request'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference response = TypeReference(
    (b) => b
      ..symbol = 'Response'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference endpointRef = TypeReference(
    (b) => b
      ..symbol = 'EndpointRef'
      ..url = 'package:frog_api/frog_api.dart',
  );

  static TypeReference list([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'List'
          ..types.add(type ?? Types.dynamic$),
      );

  static TypeReference map({
    TypeReference? keyType,
    TypeReference? valueType,
  }) =>
      TypeReference(
        (b) => b
          ..symbol = 'Map'
          ..types.add(keyType ?? Types.dynamic$)
          ..types.add(valueType ?? Types.dynamic$),
      );

  static TypeReference future([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Future'
          ..types.add(type ?? Types.dynamic$),
      );

  static TypeReference fromType(
    OpaqueType type, {
    bool? isNull,
  }) =>
      switch (type) {
        OpaqueDartType(dartType: final dartType) =>
          _fromDartType(dartType, isNull),
        OpaqueClassType(element: final element) => _fromClass(element, isNull),
      };

  static TypeReference _fromDartType(DartType dartType, [bool? isNull]) {
    if (dartType is VoidType || dartType.isDartCoreNull) {
      return void$;
    } else {
      return TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = isNull ?? dartType.isNullableType;

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(_fromDartType));
          }
        },
      );
    }
  }

  static TypeReference _fromClass(ClassElement clazz, bool? isNull) =>
      TypeReference(
        (b) {
          b
            ..symbol = clazz.name
            ..isNullable = isNull;
        },
      );
}

@internal
extension TypesX on TypeReference {
  TypeReference withNullable(bool isNullable) => TypeReference(
        (b) => b
          ..replace(this)
          ..isNullable = isNullable,
      );
}
