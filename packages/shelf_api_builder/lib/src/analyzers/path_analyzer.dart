import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/endpoint_path_parameter.dart';

@internal
class PathAnalyzer {
  static final routePattern = RegExp(r'^\[(?:\.{3})?(\w+)\](?:\.dart)?$');

  const PathAnalyzer();

  List<EndpointPathParameter> analyzePath(ClassElement clazz) =>
      _analyzePathImpl(clazz).toList();

  Iterable<EndpointPathParameter> _analyzePathImpl(ClassElement clazz) sync* {
    final sourcePathSegments = clazz.librarySource.uri.pathSegments;
    final routesIndex = sourcePathSegments.indexOf('routes');
    if (routesIndex == -1) {
      throw InvalidGenerationSource(
        'Cannot analyze files outside of the routes directory',
        element: clazz,
      );
    }

    final routeSegments = sourcePathSegments.sublist(routesIndex + 1);
    for (final routeSegment in routeSegments) {
      final routeMatch = routePattern.firstMatch(routeSegment);
      if (routeMatch == null) {
        continue;
      }

      final paramName = routeMatch[1]!;

      yield EndpointPathParameter(name: paramName);
    }
  }
}
