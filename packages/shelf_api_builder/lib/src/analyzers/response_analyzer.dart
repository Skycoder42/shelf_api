import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_response.dart';
import '../readers/api_method_reader.dart';
import '../util/type_checkers.dart';

@internal
class ResponseAnalyzer {
  const ResponseAnalyzer();

  EndpointResponse analyzeResponse(MethodElement method) =>
      _analyzeResponseImpl(method, method.returnType, true);

  EndpointResponse _analyzeResponseImpl(
    MethodElement method,
    DartType returnType,
    bool allowAsync,
  ) {
    final apiMethod = method.apiMethodAnnotation;
    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      _ensureNotNullable(returnType, method);
      return _analyzeFuture(allowAsync, method, returnType);
    } else if (apiMethod?.toJson case final String toJson) {
      return EndpointResponse(
        responseType: EndpointResponseType.json,
        toJson: toJson,
      );
    } else if (returnType.isDartAsyncStream) {
      _ensureNotNullable(returnType, method);
      return _analyzeStream(allowAsync, method, returnType);
    } else if (returnType is VoidType) {
      return const EndpointResponse(
        responseType: EndpointResponseType.noContent,
      );
    } else if (returnType.isDartCoreString) {
      _ensureNotNullable(returnType, method);
      return const EndpointResponse(responseType: EndpointResponseType.text);
    } else if (TypeCheckers.uint8List.isExactly(returnType.element!)) {
      _ensureNotNullable(returnType, method);
      return const EndpointResponse(responseType: EndpointResponseType.binary);
    } else if (TypeCheckers.response.isAssignableFrom(returnType.element!)) {
      _ensureNotNullable(returnType, method);
      return const EndpointResponse(
        responseType: EndpointResponseType.response,
      );
    } else {
      return const EndpointResponse(responseType: EndpointResponseType.json);
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

  EndpointResponse _analyzeFuture(
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

    final [futureType] = returnType.typeArgumentsOf(TypeCheckers.future)!;
    return _analyzeResponseImpl(method, futureType, false)
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
      return const EndpointResponse(
        responseType: EndpointResponseType.textStream,
      );
    } else if (TypeCheckers.intList.isAssignableFrom(streamType.element!)) {
      return const EndpointResponse(
        responseType: EndpointResponseType.binaryStream,
      );
    } else {
      throw InvalidGenerationSource(
        'Can only process streams of String or List<int>',
        element: method,
      );
    }
  }
}
