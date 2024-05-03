import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';

import '../models/endpoint_method.dart';
import '../readers/api_method_reader.dart';
import 'body_analyzer.dart';
import 'query_analyzer.dart';
import 'response_analyzer.dart';

@internal
class MethodsAnalyzer {
  final QueryAnalyzer _queryAnalyzer;
  final BodyAnalyzer _bodyAnalyzer;
  final ResponseAnalyzer _responseAnalyzer;

  MethodsAnalyzer(BuildStep buildStep)
      : _queryAnalyzer = QueryAnalyzer(buildStep),
        _bodyAnalyzer = BodyAnalyzer(buildStep),
        _responseAnalyzer = ResponseAnalyzer(buildStep);

  Future<List<EndpointMethod>> analyzeMethods(ClassElement clazz) =>
      _analyzeMethods(clazz).toList();

  Stream<EndpointMethod> _analyzeMethods(ClassElement clazz) async* {
    for (final method in clazz.methods) {
      final apiMethod = method.apiMethodAnnotation;
      if (apiMethod == null) {
        continue;
      }

      yield await _analyzeMethod(method, apiMethod);
    }
  }

  Future<EndpointMethod> _analyzeMethod(
    MethodElement method,
    ApiMethodReader apiMethod,
  ) async =>
      EndpointMethod(
        name: method.name,
        httpMethod: apiMethod.method,
        path: apiMethod.path,
        queryParameters: await _queryAnalyzer.analyzeQuery(method),
        body: await _bodyAnalyzer.analyzeBody(method),
        response: await _responseAnalyzer.analyzeResponse(method),
      );
}
