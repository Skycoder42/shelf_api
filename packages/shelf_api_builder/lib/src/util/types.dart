import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../models/opaque_type.dart';
import '../models/serializable_type.dart';

@internal
abstract base class Types {
  Types._();

  static final uint8List = TypeReference(
    (b) => b
      ..symbol = 'Uint8List'
      ..url = 'dart:typed_data',
  );

  static final shelfRequest = TypeReference(
    (b) => b
      ..symbol = 'Request'
      ..url = 'package:shelf/shelf.dart',
  );

  static final shelfResponse = TypeReference(
    (b) => b
      ..symbol = 'Response'
      ..url = 'package:shelf/shelf.dart',
  );

  static final handler = TypeReference(
    (b) => b
      ..symbol = 'Handler'
      ..url = 'package:shelf/shelf.dart',
  );

  static final pipeline = TypeReference(
    (b) => b
      ..symbol = 'Pipeline'
      ..url = 'package:shelf/shelf.dart',
  );

  static final router = TypeReference(
    (b) => b
      ..symbol = 'Router'
      ..url = 'package:shelf_router/shelf_router.dart',
  );

  static final dio = TypeReference(
    (b) => b
      ..symbol = 'Dio'
      ..url = 'package:dio/dio.dart',
  );

  static final responseType = TypeReference(
    (b) => b
      ..symbol = 'ResponseType'
      ..url = 'package:dio/dio.dart',
  );

  static final responseBody = TypeReference(
    (b) => b
      ..symbol = 'ResponseBody'
      ..url = 'package:dio/dio.dart',
  );

  static final baseOptions = TypeReference(
    (b) => b
      ..symbol = 'BaseOptions'
      ..url = 'package:dio/dio.dart',
  );

  static final options = TypeReference(
    (b) => b
      ..symbol = 'Options'
      ..url = 'package:dio/dio.dart',
  );

  static final cancelToken = TypeReference(
    (b) => b
      ..symbol = 'CancelToken'
      ..url = 'package:dio/dio.dart',
  );

  static final progressCallback = TypeReference(
    (b) => b
      ..symbol = 'ProgressCallback'
      ..url = 'package:dio/dio.dart',
  );

  static final dioException = TypeReference(
    (b) => b
      ..symbol = 'DioException'
      ..url = 'package:dio/dio.dart',
  );

  static final dioExceptionType = TypeReference(
    (b) => b
      ..symbol = 'DioExceptionType'
      ..url = 'package:dio/dio.dart',
  );

  static final httpMethod = TypeReference(
    (b) => b
      ..symbol = 'HttpMethod'
      ..url = 'package:shelf_api/shelf_api.dart',
  );

  static final endpointRef = TypeReference(
    (b) => b
      ..symbol = 'EndpointRef'
      ..url = 'package:shelf_api/shelf_api.dart',
  );

  static final contentTypes = TypeReference(
    (b) => b
      ..symbol = 'ContentTypes'
      ..url = 'package:shelf_api/shelf_api.dart',
  );

  static TypeReference futureOr([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'FutureOr'
      ..types.add(type ?? CoreTypes.$dynamic)
      ..url = 'dart:async',
  );

  static TypeReference stream([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'Stream'
      ..types.add(type ?? CoreTypes.$dynamic)
      ..url = 'dart:async',
  );

  static TypeReference dioRequest([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'Request'
      ..types.add(type ?? CoreTypes.$dynamic)
      ..url = 'package:dio/dio.dart',
  );

  static TypeReference dioResponse([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'Response'
      ..types.add(type ?? CoreTypes.$dynamic)
      ..url = 'package:dio/dio.dart',
  );

  static TypeReference tResponseBody([Reference? type]) => TypeReference(
    (b) => b
      ..symbol = 'TResponseBody'
      ..types.addAll([?type])
      ..url = 'package:shelf_api/shelf_api_client.dart',
  );

  static Reference fromType(OpaqueType type, {bool? isNull}) => switch (type) {
    OpaqueSerializableType(serializableType: final type) =>
      _fromSerializableType(type, isNull),
    final OpaqueDartType dartType => _fromDartType(
      dartType.dartType,
      dartType.uri,
      isNull,
    ),
    final OpaqueClassType classType => _fromClass(
      classType.element,
      classType.uri,
      isNull,
    ),
    OpaqueDynamicType() => CoreTypes.$dynamic,
  };

  static Reference _fromDartType(DartType dartType, [Uri? uri, bool? isNull]) {
    final ref = dartType.toReference(nullable: isNull);
    if (ref.type case final TypeReference typeRef when uri != null) {
      return TypeReference(
        (b) => b
          ..replace(typeRef)
          ..url = uri.toString(),
      );
    } else {
      return ref;
    }
  }

  static TypeReference _fromClass(ClassElement clazz, Uri? uri, bool? isNull) {
    final ref = clazz.toReference(nullable: isNull ?? false);
    if (ref.type case final TypeReference typeRef when uri != null) {
      return TypeReference(
        (b) => b
          ..replace(typeRef)
          ..url = uri.toString(),
      );
    } else {
      return ref;
    }
  }

  static Reference _fromSerializableType(
    SerializableType serializableType,
    bool? isNull,
  ) => switch (serializableType.wrapped) {
    .none => Types.fromType(serializableType.dartType, isNull: isNull),
    .list => CoreTypes.$List(
      Types.fromType(serializableType.dartType),
    ).withNullable(isNull ?? serializableType.isNullable),
    .map => CoreTypes.$Map(
      keyType: CoreTypes.$String,
      valueType: Types.fromType(serializableType.dartType),
    ).withNullable(isNull ?? serializableType.isNullable),
  };
}

@internal
extension TypesX on TypeReference {
  // ignore: avoid_positional_boolean_parameters for single parameter
  TypeReference withNullable(bool isNullable) => TypeReference(
    (b) => b
      ..replace(this)
      ..isNullable = isNullable,
  );
}
