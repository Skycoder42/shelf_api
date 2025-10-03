import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_response.dart';
import '../models/opaque_type.dart';
import '../readers/api_method_reader.dart';
import '../util/type_checkers.dart';
import 'serializable_analyzer.dart';

@internal
class ResponseAnalyzer {
  final BuildStep _buildStep;
  final SerializableAnalyzer _serializableAnalyzer;

  ResponseAnalyzer(this._buildStep)
    : _serializableAnalyzer = SerializableAnalyzer(_buildStep);

  Future<EndpointResponse> analyzeResponse(
    MethodElement2 method,
    ApiMethodReader apiMethod,
  ) => _analyzeResponseImpl(method, apiMethod, method.returnType, true);

  Future<EndpointResponse> _analyzeResponseImpl(
    MethodElement2 method,
    ApiMethodReader apiMethod,
    DartType returnType,
    bool allowAsync,
  ) async {
    if (returnType is DynamicType) {
      throw InvalidGenerationSource(
        'Cannot generate code for dynamic return types',
        todo: 'Use a specific type or return Response instead.',
        element: method,
      );
    }

    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      _ensureNotNullable(returnType, method);
      return _analyzeFuture(method, apiMethod, returnType, allowAsync);
    } else if (_serializableAnalyzer.isCustom(apiMethod)) {
      return EndpointResponse(
        responseType: EndpointResponseType.json,
        returnType: await _serializableAnalyzer.analyzeType(
          method,
          returnType,
          apiMethod,
        ),
      );
    } else if (returnType.isDartAsyncStream) {
      _ensureNotNullable(returnType, method);
      return _analyzeStream(allowAsync, method, returnType);
    } else if (returnType is VoidType) {
      return EndpointResponse(
        responseType: EndpointResponseType.noContent,
        returnType: OpaqueDartType(_buildStep, returnType),
      );
    } else if (returnType.isDartCoreString) {
      _ensureNotNullable(returnType, method);
      return EndpointResponse(
        responseType: EndpointResponseType.text,
        returnType: OpaqueDartType(_buildStep, returnType),
      );
    } else if (TypeCheckers.uint8List.isExactlyType(returnType)) {
      _ensureNotNullable(returnType, method);
      return EndpointResponse(
        responseType: EndpointResponseType.binary,
        returnType: OpaqueDartType(_buildStep, returnType),
      );
    } else if (TypeCheckers.tResponse.isExactlyType(returnType)) {
      _ensureNotNullable(returnType, method);
      return await _analyzeTResponse(method, apiMethod, returnType);
    } else if (TypeCheckers.response.isAssignableFromType(returnType)) {
      _ensureNotNullable(returnType, method);
      return EndpointResponse(
        responseType: EndpointResponseType.dynamic,
        returnType: OpaqueDynamicType(),
        isResponse: true,
      );
    } else {
      return EndpointResponse(
        responseType: EndpointResponseType.json,
        returnType: await _serializableAnalyzer.analyzeType(
          method,
          returnType,
          apiMethod,
        ),
      );
    }
  }

  void _ensureNotNullable(DartType returnType, MethodElement2 method) {
    if (returnType.isNullableType) {
      throw InvalidGenerationSource(
        'Non JSON return types cannot be nullable!',
        todo: 'Make the type non nullable.',
        element: method,
      );
    }
  }

  Future<EndpointResponse> _analyzeFuture(
    MethodElement2 method,
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
    return (await _analyzeResponseImpl(
      method,
      apiMethod,
      futureType,
      false,
    )).copyWith(isAsync: true);
  }

  Future<EndpointResponse> _analyzeTResponse(
    MethodElement2 method,
    ApiMethodReader apiMethod,
    DartType returnType,
  ) async {
    final [responseType] = returnType.typeArgumentsOf(TypeCheckers.tResponse)!;
    return (await _analyzeResponseImpl(
      method,
      apiMethod,
      responseType,
      false,
    )).copyWith(isResponse: true);
  }

  EndpointResponse _analyzeStream(
    bool allowAsync,
    MethodElement2 method,
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
        returnType: OpaqueDartType(_buildStep, returnType),
      );
    } else if (TypeCheckers.intList.isAssignableFromType(streamType)) {
      return EndpointResponse(
        responseType: EndpointResponseType.binaryStream,
        returnType: OpaqueDartType(_buildStep, returnType),
      );
    } else {
      throw InvalidGenerationSource(
        'Can only process streams of String or List<int>',
        element: method,
      );
    }
  }
}
