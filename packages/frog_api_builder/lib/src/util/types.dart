import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

@internal
abstract base class Types {
  Types._();

  static final void$ = TypeReference((b) => b..symbol = 'void');

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

  static TypeReference future(TypeReference type) => TypeReference(
        (b) => b
          ..symbol = 'Future'
          ..types.add(type),
      );

  static TypeReference fromDartType(
    DartType dartType, {
    bool? isNull,
  }) {
    if (dartType is VoidType || dartType.isDartCoreNull) {
      return void$;
    } else {
      return TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = isNull ?? dartType.isNullableType;

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(fromDartType));
          }
        },
      );
    }
  }

  static TypeReference fromClass(
    ClassElement clazz, {
    bool? isNull,
  }) =>
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
  TypeReference get nullable => TypeReference(
        (b) => b
          ..replace(this)
          ..isNullable = true,
      );
}
