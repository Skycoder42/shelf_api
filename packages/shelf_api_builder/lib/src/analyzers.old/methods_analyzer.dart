// ignore_for_file: avoid_field_initializers_in_const_classes

import 'package:analyzer/dart/element/element.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/endpoint_method.dart';
import '../readers/api_method_reader.dart';
import 'body_analyzer.dart';
import '../analyzers/query_analyzer.dart';
import '../analyzers/response_analyzer.dart';

@internal
class MethodsAnalyzer {
  final BodyAnalyzer _bodyAnalyzer;
  final QueryAnalyzer _queryAnalyzer;
  final ResponseAnalyzer _responseAnalyzer;

  const MethodsAnalyzer()
      : _bodyAnalyzer = const BodyAnalyzer(),
        _queryAnalyzer = const QueryAnalyzer(),
        _responseAnalyzer = const ResponseAnalyzer();

  Map<HttpMethod, EndpointMethod> analyzeMethods(ClassElement clazz) {
    final annotatedMethods = <HttpMethod, EndpointMethod>{};
    final namedMethods = <HttpMethod, EndpointMethod>{};

    for (final method in clazz.methods) {
      if (method.isStatic) {
        continue;
      }

      final methodAnnotation = method.apiMethodAnnotation;
      if (methodAnnotation != null) {
        annotatedMethods.update(
          methodAnnotation.method,
          (value) => throw InvalidGenerationSourceError(
            'Cannot mark method as HTTP ${methodAnnotation.method.value} - '
            'another method already declares this annotation.',
            element: method,
          ),
          ifAbsent: () => _parseMethod(method, methodAnnotation),
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

  EndpointMethod _parseMethod(
    MethodElement method, [
    ApiMethodReader? methodAnnotation,
  ]) {
    final body = _bodyAnalyzer.analyzeBody(method, methodAnnotation);
    return EndpointMethod(
      name: method.name,
      response: _responseAnalyzer.analyzeResponse(method),
      body: body,
      queryParameters: _queryAnalyzer.analyzeQuery(method, body != null),
    );
  }
}
