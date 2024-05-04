import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_response.dart';
import '../models/opaque_type.dart';
import '../readers/api_method_reader.dart';
import '../util/type_checkers.dart';

@internal
class ResponseAnalyzer {
  final BuildStep _buildStep;

  ResponseAnalyzer(this._buildStep);

  Future<EndpointResponse> analyzeResponse(
    MethodElement method,
    ApiMethodReader apiMethod,
  ) =>
      _analyzeResponseImpl(method, apiMethod, method.returnType, true);

  Future<EndpointResponse> _analyzeResponseImpl(
    MethodElement method,
    ApiMethodReader apiMethod,
    DartType returnType,
    bool allowAsync,
  ) async {
    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      _ensureNotNullable(returnType, method);
      return _analyzeFuture(method, apiMethod, returnType, allowAsync);
    } else if (apiMethod.hasToJson) {
      return EndpointResponse(
        responseType: EndpointResponseType.json,
        rawType: OpaqueDartType(returnType),
        toJson: await apiMethod.toJson(_buildStep),
      );
    } else if (returnType.isDartAsyncStream) {
      _ensureNotNullable(returnType, method);
      return _analyzeStream(allowAsync, method, returnType);
    } else if (returnType is VoidType) {
      return EndpointResponse(
        responseType: EndpointResponseType.noContent,
        rawType: OpaqueDartType(returnType),
      );
    } else if (returnType.isDartCoreString) {
      _ensureNotNullable(returnType, method);
      return EndpointResponse(
        responseType: EndpointResponseType.text,
        rawType: OpaqueDartType(returnType),
      );
    } else if (TypeCheckers.uint8List.isExactly(returnType.element!)) {
      _ensureNotNullable(returnType, method);
      return EndpointResponse(
        responseType: EndpointResponseType.binary,
        rawType: OpaqueDartType(returnType),
      );
    } else if (TypeCheckers.tResponse.isExactly(returnType.element!)) {
      _ensureNotNullable(returnType, method);
      final [responseType] =
          returnType.typeArgumentsOf(TypeCheckers.tResponse)!;
      return EndpointResponse(
        responseType: EndpointResponseType.response,
        rawType: OpaqueDartType(responseType),
      );
    } else if (TypeCheckers.response.isAssignableFrom(returnType.element!)) {
      _ensureNotNullable(returnType, method);
      return const EndpointResponse(
        responseType: EndpointResponseType.response,
        rawType: OpaqueVoidType(),
      );
    } else {
      return EndpointResponse(
        responseType: EndpointResponseType.json,
        rawType: OpaqueDartType(returnType),
      );
    }
  }

  void _ensureNotNullable(DartType returnType, MethodElement method) {
    if (returnType.isNullableType) {
      throw InvalidGenerationSource(
        'Non JSON return types cannot be nullable!',
        todo: 'Make the type non nullable.',
        element: method,
      );
    }
  }

  Future<EndpointResponse> _analyzeFuture(
    MethodElement method,
    ApiMethodReader apiMethod,
    DartType returnType,
    bool allowAsync,
  ) async {
    if (!allowAsync) {
      throw InvalidGenerationSource(
        'Cannot process nested Futures',
        element: method,
      );
    }

    final [futureType] = returnType.typeArgumentsOf(TypeCheckers.future)!;
    return (await _analyzeResponseImpl(method, apiMethod, futureType, false))
        .copyWith(isAsync: true);
  }

  EndpointResponse _analyzeStream(
    bool allowAsync,
    MethodElement method,
    DartType returnType,
  ) {
    if (!allowAsync) {
      throw InvalidGenerationSource(
        'Cannot process nested Futures',
        element: method,
      );
    }

    final [streamType] = returnType.typeArgumentsOf(TypeCheckers.stream)!;
    if (streamType.isDartCoreString) {
      return EndpointResponse(
        responseType: EndpointResponseType.textStream,
        rawType: OpaqueDartType(returnType),
      );
    } else if (TypeCheckers.intList.isAssignableFrom(streamType.element!)) {
      return EndpointResponse(
        responseType: EndpointResponseType.binaryStream,
        rawType: OpaqueDartType(returnType),
      );
    } else {
      throw InvalidGenerationSource(
        'Can only process streams of String or List<int>',
        element: method,
      );
    }
  }
}
