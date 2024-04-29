import 'dart:typed_data';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'frog_method_reader.dart';

@internal
enum EndpointReturnType {
  noContent,
  string,
  bytes,
  stringStream,
  byteStream,
  json,
  response,
}

@immutable
@internal
class EndpointMethodParameter {
  final String name;
  final DartType type;
  final bool optional;

  const EndpointMethodParameter({
    required this.name,
    required this.type,
    required this.optional,
  });
}

@internal
@immutable
class EndpointMethod {
  final MethodElement element;
  final EndpointReturnType returnType;
  final bool isAsync;
  final List<EndpointMethodParameter> queryParameters;

  const EndpointMethod({
    required this.element,
    required this.returnType,
    required this.isAsync,
    required this.queryParameters,
  });
}

@internal
class EndpointMethodsReader {
  const EndpointMethodsReader();

  Map<HttpMethod, EndpointMethod> readMethods(ClassElement clazz) {
    final annotatedMethods = <HttpMethod, EndpointMethod>{};
    final namedMethods = <HttpMethod, EndpointMethod>{};

    for (final method in clazz.methods) {
      if (method.isStatic) {
        continue;
      }

      final methodAnnotation = method.frogMethodAnnotation;
      if (methodAnnotation != null) {
        annotatedMethods.update(
          methodAnnotation.method,
          (value) => throw InvalidGenerationSourceError(
            'Cannot mark method as HTTP ${methodAnnotation.method.value} - '
            'another method already declares this annotation.',
            element: method,
          ),
          ifAbsent: () => _parseMethod(method),
        );
        continue;
      }

      final namedMethod = _methodFromName(method);
      if (namedMethod != null) {
        namedMethods[namedMethod] = _parseMethod(method);
      }

      namedMethods.addAll(annotatedMethods);
      return namedMethods;
    }

    return <HttpMethod, EndpointMethod>{}
      ..addAll(namedMethods)
      ..addAll(annotatedMethods);
  }

  HttpMethod? _methodFromName(MethodElement method) {
    final normalizedName = method.name.toUpperCase();
    return HttpMethod.values
        .where((m) => m.value == normalizedName)
        .singleOrNull;
  }

  EndpointMethod _parseMethod(MethodElement method) {
    // detect return type
    final (returnType, isAsync) = _findReturnType(method, method.returnType);
    return EndpointMethod(
      element: method,
      returnType: returnType,
      isAsync: isAsync,
      queryParameters: const [],
    );
  }

  (EndpointReturnType, bool) _findReturnType(
    MethodElement method,
    DartType returnType, {
    bool allowAsync = true,
  }) {
    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      if (!allowAsync) {
        throw InvalidGenerationSource(
          'Cannot process nested Futures',
          element: method,
        );
      }

      final futureType = returnType
          .typeArgumentsOf(const TypeChecker.fromRuntime(Future))!
          .single;
      return (_findReturnType(method, futureType, allowAsync: false).$1, true);
    }

    if (returnType.isDartAsyncStream) {
      if (!allowAsync) {
        throw InvalidGenerationSource(
          'Cannot process nested Futures',
          element: method,
        );
      }

      final streamType = returnType
          .typeArgumentsOf(const TypeChecker.fromRuntime(Stream))!
          .single;
      if (streamType.isDartCoreString) {
        return (EndpointReturnType.stringStream, false);
      } else if (const TypeChecker.fromRuntime(List<int>)
          .isAssignableFrom(streamType.element!)) {
        return (EndpointReturnType.byteStream, false);
      } else {
        throw InvalidGenerationSource(
          'Can only process streams of String or List<int>',
          element: method,
        );
      }
    }

    if (returnType is VoidType) {
      return (EndpointReturnType.noContent, false);
    } else if (returnType.isDartCoreString) {
      return (EndpointReturnType.string, false);
    } else if (const TypeChecker.fromRuntime(Uint8List)
        .isExactly(returnType.element!)) {
      return (EndpointReturnType.bytes, false);
    } else if (const TypeChecker.fromRuntime(Response)
        .isAssignableFrom(returnType.element!)) {
      return (EndpointReturnType.response, false);
    } else {
      return (EndpointReturnType.json, false);
    }
  }
}
