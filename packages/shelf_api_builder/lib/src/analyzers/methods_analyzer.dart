import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import '../models/endpoint_method.dart';
import '../readers/api_method_reader.dart';
import 'response_analyzer.dart';

@internal
class MethodsAnalyzer {
  final ResponseAnalyzer _responseAnalyzer;

  const MethodsAnalyzer([
    this._responseAnalyzer = const ResponseAnalyzer(),
  ]);

  List<EndpointMethod> analyzeMethods(ClassElement clazz) =>
      _analyzeMethods(clazz).toList();

  Iterable<EndpointMethod> _analyzeMethods(ClassElement clazz) sync* {
    for (final method in clazz.methods) {
      final apiMethod = method.apiMethodAnnotation;
      if (apiMethod == null) {
        continue;
      }

      yield _analyzeMethod(method, apiMethod);
    }
  }

  EndpointMethod _analyzeMethod(
    MethodElement method,
    ApiMethodReader apiMethod,
  ) =>
      EndpointMethod(
        name: method.name,
        httpMethod: apiMethod.method,
        path: apiMethod.path,
        response: _responseAnalyzer.analyzeResponse(method),
      );
}
