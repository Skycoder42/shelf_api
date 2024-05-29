import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../analyzers/methods_analyzer.dart';
import '../models/endpoint.dart';
import '../models/opaque_type.dart';
import '../readers/api_endpoint_reader.dart';
import '../util/type_checkers.dart';

@internal
class EndpointAnalyzer {
  final BuildStep _buildStep;
  final MethodsAnalyzer _methodsAnalyzer;

  EndpointAnalyzer(this._buildStep)
      : _methodsAnalyzer = MethodsAnalyzer(_buildStep);

  Future<Endpoint> analyzeEndpoint(
    DartType endpointType,
    ClassElement apiElement,
  ) async {
    final endpointElement = endpointType.element;
    if (endpointElement is! ClassElement ||
        !TypeCheckers.shelfEndpoint.isSuperOf(endpointElement)) {
      throw InvalidGenerationSource(
        'Endpoints of ShelfApi must extend ShelfEndpoint!',
        element: apiElement,
      );
    }

    final apiEndpoint = endpointElement.apiEndpointAnnotation;
    if (apiEndpoint != null) {
      if (apiEndpoint.hasMiddleware && apiEndpoint.path == '/') {
        throw InvalidGenerationSource(
          'Endpoints with a middleware must specify a path '
          'that is different from "/"!',
          todo: 'Use a custom path, move the middleware to the ShelfApi '
              'or remove it.',
        );
      }
    }

    return Endpoint(
      endpointType: OpaqueClassType(_buildStep, endpointElement),
      name: endpointElement.name,
      path: apiEndpoint?.path,
      methods: await _methodsAnalyzer.analyzeMethods(endpointElement),
      middleware: await apiEndpoint?.middleware(_buildStep),
    );
  }
}
