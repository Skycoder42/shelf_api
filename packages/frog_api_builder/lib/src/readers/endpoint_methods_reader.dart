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
  text,
  binary,
  textStream,
  binaryStream,
  json,
  response,
}

@internal
enum EndpointBodyType {
  text,
  binary,
  formData,
  json,
}

@internal
@immutable
class EndpointMethodBody {
  final DartType paramType;
  final EndpointBodyType bodyType;

  const EndpointMethodBody({
    required this.paramType,
    required this.bodyType,
  });
}

@internal
@immutable
class EndpointMethodParameter {
  final String name;
  final DartType type;
  final bool optional;
  final String? defaultValue;

  const EndpointMethodParameter({
    required this.name,
    required this.type,
    required this.optional,
    required this.defaultValue,
  });
}

@internal
@immutable
class EndpointMethod {
  final MethodElement element;
  final EndpointReturnType returnType;
  final bool isAsync;
  final EndpointMethodBody? body;
  final List<EndpointMethodParameter> queryParameters;

  const EndpointMethod({
    required this.element,
    required this.returnType,
    required this.isAsync,
    required this.body,
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
    final body = _getMethodBody(method);
    return EndpointMethod(
      element: method,
      returnType: returnType,
      isAsync: isAsync,
      body: body,
      queryParameters: _findParameters(method, body != null).toList(),
    );
  }

  EndpointMethodBody? _getMethodBody(MethodElement method) {
    final bodyParam = method.parameters.firstOrNull;
    if (bodyParam == null || !bodyParam.isRequiredPositional) {
      return null;
    }

    final paramType = bodyParam.type;
    if (paramType.isDartCoreString) {
      return EndpointMethodBody(
        paramType: bodyParam.type,
        bodyType: EndpointBodyType.text,
      );
    } else if (const TypeChecker.fromRuntime(Uint8List)
        .isAssignableFrom(paramType.element!)) {
      return EndpointMethodBody(
        paramType: bodyParam.type,
        bodyType: EndpointBodyType.binary,
      );
    } else if (const TypeChecker.fromRuntime(FormData)
        .isExactly(paramType.element!)) {
      return EndpointMethodBody(
        paramType: bodyParam.type,
        bodyType: EndpointBodyType.formData,
      );
    } else {
      return EndpointMethodBody(
        paramType: paramType,
        bodyType: EndpointBodyType.json,
      );
    }
  }

  Iterable<EndpointMethodParameter> _findParameters(
    MethodElement method,
    bool hasBodyParam,
  ) sync* {
    final parameters =
        hasBodyParam ? method.parameters.skip(1) : method.parameters;

    for (final param in parameters) {
      if (param.isPositional) {
        throw InvalidGenerationSource(
          'Only named parameters can be used',
          element: method,
        );
      }

      if (param.type.isNullableType &&
          (param.isRequired || param.hasDefaultValue)) {
        throw InvalidGenerationSource(
          'Nullable parameters can neither be required nor have a default value',
          element: method,
        );
      }

      yield EndpointMethodParameter(
        name: param.name,
        type: param.type,
        optional: param.isOptional,
        defaultValue: param.defaultValueCode,
      );
    }
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
        return (EndpointReturnType.textStream, false);
      } else if (const TypeChecker.fromRuntime(List<int>)
          .isAssignableFrom(streamType.element!)) {
        return (EndpointReturnType.binaryStream, false);
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
      return (EndpointReturnType.text, false);
    } else if (const TypeChecker.fromRuntime(Uint8List)
        .isExactly(returnType.element!)) {
      return (EndpointReturnType.binary, false);
    } else if (const TypeChecker.fromRuntime(Response)
        .isAssignableFrom(returnType.element!)) {
      return (EndpointReturnType.response, false);
    } else {
      return (EndpointReturnType.json, false);
    }
  }
}
