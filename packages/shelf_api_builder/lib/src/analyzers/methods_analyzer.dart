import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';

import '../models/endpoint_method.dart';
import '../readers/api_method_reader.dart';
import '../readers/shelf_api_reader.dart';
import 'body_analyzer.dart';
import 'path_analyzer.dart';
import 'query_analyzer.dart';
import 'response_analyzer.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
class MethodsAnalyzer(BuildStep buildStep) {
  final _bodyAnalyzer = BodyAnalyzer(buildStep);
  final _pathAnalyzer = PathAnalyzer(buildStep);
  final _queryAnalyzer = QueryAnalyzer(buildStep);
  final _responseAnalyzer = ResponseAnalyzer(buildStep);

  Future<List<EndpointMethod>> analyzeMethods(
    ClassElement clazz,
    ShelfApiReader shelfApi,
  ) => _analyzeMethods(clazz, shelfApi).toList();

  Stream<EndpointMethod> _analyzeMethods(
    ClassElement clazz,
    ShelfApiReader shelfApi,
  ) async* {
    for (final method in clazz.methods) {
      final apiMethod = method.apiMethodAnnotation;
      if (apiMethod == null) {
        continue;
      }

      yield await _analyzeMethod(method, apiMethod, shelfApi);
    }
  }

  Future<EndpointMethod> _analyzeMethod(
    MethodElement method,
    ApiMethodReader apiMethod,
    ShelfApiReader shelfApi,
  ) async => EndpointMethod(
    name: method.name!,
    httpMethod: apiMethod.method,
    path: apiMethod.path,
    pathParameters: await _pathAnalyzer.analyzePath(method, apiMethod),
    body: await _bodyAnalyzer.analyzeBody(method),
    queryParameters: await _queryAnalyzer.analyzeQuery(method),
    response: await _responseAnalyzer.analyzeResponse(
      method,
      apiMethod,
      shelfApi,
    ),
  );
}
