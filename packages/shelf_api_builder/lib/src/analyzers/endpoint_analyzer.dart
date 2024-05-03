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
  final MethodsAnalyzer _methodsAnalyzer;

  EndpointAnalyzer(BuildStep buildStep)
      : _methodsAnalyzer = MethodsAnalyzer(buildStep);

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
    return Endpoint(
      endpointType: OpaqueClassType(endpointElement),
      name: endpointElement.name,
      path: apiEndpoint?.path,
      methods: await _methodsAnalyzer.analyzeMethods(endpointElement),
    );
  }
}
