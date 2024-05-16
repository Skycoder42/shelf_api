import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../models/opaque_type.dart';
import '../models/serializable_type.dart';

@internal
abstract base class Types {
  Types._();

  static final dynamic$ = TypeReference((b) => b..symbol = 'dynamic');

  static final void$ = TypeReference((b) => b..symbol = 'void');

  static final bool$ = TypeReference((b) => b..symbol = 'bool');

  static final int$ = TypeReference((b) => b..symbol = 'int');

  static final string = TypeReference((b) => b..symbol = 'String');

  static final uri = TypeReference((b) => b..symbol = 'Uri');

  static final TypeReference uint8List = TypeReference(
    (b) => b
      ..symbol = 'Uint8List'
      ..url = 'dart:typed_data',
  );

  static final TypeReference shelfRequest = TypeReference(
    (b) => b
      ..symbol = 'Request'
      ..url = 'package:shelf/shelf.dart',
  );

  static final TypeReference shelfResponse = TypeReference(
    (b) => b
      ..symbol = 'Response'
      ..url = 'package:shelf/shelf.dart',
  );

  static final TypeReference router = TypeReference(
    (b) => b
      ..symbol = 'Router'
      ..url = 'package:shelf_router/shelf_router.dart',
  );

  static final TypeReference dio = TypeReference(
    (b) => b
      ..symbol = 'Dio'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference responseType = TypeReference(
    (b) => b
      ..symbol = 'ResponseType'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference responseBody = TypeReference(
    (b) => b
      ..symbol = 'ResponseBody'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference baseOptions = TypeReference(
    (b) => b
      ..symbol = 'BaseOptions'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference options = TypeReference(
    (b) => b
      ..symbol = 'Options'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference cancelToken = TypeReference(
    (b) => b
      ..symbol = 'CancelToken'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference progressCallback = TypeReference(
    (b) => b
      ..symbol = 'ProgressCallback'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference dioException = TypeReference(
    (b) => b
      ..symbol = 'DioException'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference dioExceptionType = TypeReference(
    (b) => b
      ..symbol = 'DioExceptionType'
      ..url = 'package:dio/dio.dart',
  );

  static final TypeReference httpMethod = TypeReference(
    (b) => b
      ..symbol = 'HttpMethod'
      ..url = 'package:shelf_api/shelf_api.dart',
  );

  static final TypeReference endpointRef = TypeReference(
    (b) => b
      ..symbol = 'EndpointRef'
      ..url = 'package:shelf_api/shelf_api.dart',
  );

  static final TypeReference contentTypes = TypeReference(
    (b) => b
      ..symbol = 'ContentTypes'
      ..url = 'package:shelf_api/shelf_api.dart',
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

  static TypeReference futureOr([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'FutureOr'
          ..types.add(type ?? Types.dynamic$)
          ..url = 'dart:async',
      );

  static TypeReference stream([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Stream'
          ..types.add(type ?? Types.dynamic$),
      );

  static TypeReference dioRequest([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Request'
          ..types.add(type ?? Types.dynamic$)
          ..url = 'package:dio/dio.dart',
      );

  static TypeReference dioResponse([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'Response'
          ..types.add(type ?? Types.dynamic$)
          ..url = 'package:dio/dio.dart',
      );

  static TypeReference tResponseBody([TypeReference? type]) => TypeReference(
        (b) => b
          ..symbol = 'TResponseBody'
          ..types.addAll([
            if (type != null) type,
          ])
          ..url = 'package:shelf_api/shelf_api_client.dart',
      );

  static TypeReference fromType(
    OpaqueType type, {
    bool? isNull,
  }) =>
      switch (type) {
        OpaqueSerializableType(serializableType: final type) =>
          _fromSerializableType(type, isNull),
        final OpaqueDartType dartType =>
          _fromDartType(dartType.dartType, dartType.uri, isNull),
        final OpaqueClassType classType =>
          _fromClass(classType.element, classType.uri, isNull),
        OpaqueDynamicType() => dynamic$,
      };

  static TypeReference _fromDartType(
    DartType dartType, [
    Uri? uri,
    bool? isNull,
  ]) {
    if (dartType is VoidType || dartType.isDartCoreNull) {
      return void$;
    } else if (dartType is DynamicType) {
      return dynamic$;
    } else {
      return TypeReference(
        (b) {
          b
            ..symbol = dartType.element!.name
            ..isNullable = isNull ?? dartType.isNullableType
            ..url = uri?.toString() ??
                dartType.element?.librarySource?.uri.toString();

          if (dartType is InterfaceType) {
            b.types.addAll(dartType.typeArguments.map(_fromDartType));
          }
        },
      );
    }
  }

  static TypeReference _fromClass(ClassElement clazz, Uri? uri, bool? isNull) =>
      TypeReference(
        (b) {
          b
            ..symbol = clazz.name
            ..isNullable = isNull
            ..url = uri?.toString() ?? clazz.librarySource.uri.toString();
        },
      );

  static TypeReference _fromSerializableType(
    SerializableType serializableType,
    bool? isNull,
  ) =>
      switch (serializableType.wrapped) {
        Wrapped.none =>
          Types.fromType(serializableType.dartType, isNull: isNull),
        Wrapped.list => Types.list(Types.fromType(serializableType.dartType))
            .withNullable(isNull ?? serializableType.isNullable),
        Wrapped.map => Types.map(
            keyType: Types.string,
            valueType: Types.fromType(serializableType.dartType),
          ).withNullable(isNull ?? serializableType.isNullable),
      };
}

@internal
extension TypesX on TypeReference {
  TypeReference withNullable(bool isNullable) => TypeReference(
        (b) => b
          ..replace(this)
          ..isNullable = isNullable,
      );
}
