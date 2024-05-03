import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/api_class.dart';
import '../models/opaque_type.dart';
import '../readers/shelf_api_reader.dart';
import 'endpoint_analyzer.dart';

@internal
class ApiClassAnalyzer {
  final EndpointAnalyzer _endpointAnalyzer;

  ApiClassAnalyzer(BuildStep buildStep)
      : _endpointAnalyzer = EndpointAnalyzer(buildStep);

  Future<ApiClass> analyzeApiClass(
    ClassElement clazz,
    ShelfApiReader shelfApi,
  ) async {
    if (shelfApi.endpoints.isEmpty) {
      throw InvalidGenerationSourceError(
        'The ShelfApi annotation must define at least one endpoint.',
        element: clazz,
      );
    }

    return ApiClass(
      classType: OpaqueClassType(clazz),
      className: clazz.name,
      endpoints: [
        for (final endpoint in shelfApi.endpoints)
          await _endpointAnalyzer.analyzeEndpoint(endpoint, clazz),
      ],
    );
  }
}
