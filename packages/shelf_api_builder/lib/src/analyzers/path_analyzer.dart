import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_path_parameter.dart';
import '../models/opaque_type.dart';
import '../readers/api_method_reader.dart';
import '../readers/body_param_reader.dart';
import '../readers/path_param_reader.dart';
import '../util/type_checkers.dart';

@internal
class PathAnalyzer {
  // Based on https://github.com/dart-lang/shelf/blob/master/pkgs/shelf_router/lib/src/router_entry.dart#L31
  final _pathParamRegexp = RegExp(r'<([^>|]+)(?:\|[^>]*)?>');

  final BuildStep _buildStep;

  PathAnalyzer(this._buildStep);

  Future<List<EndpointPathParameter>> analyzePath(
    MethodElement method,
    ApiMethodReader apiMethod,
  ) =>
      _analyzePath(method, apiMethod).toList();

  Stream<EndpointPathParameter> _analyzePath(
    MethodElement method,
    ApiMethodReader apiMethod,
  ) async* {
    final pathParamMatches = _pathParamRegexp
        .allMatches(apiMethod.path)
        .map((match) => match[1]!)
        .toList();

    for (final param in method.parameters.where((p) => p.isPositional)) {
      if (param.bodyParamAnnotation != null) {
        if (pathParamMatches.isEmpty) {
          continue;
        }

        throw InvalidGenerationSource(
          'Found ${pathParamMatches.length} remaining path parameter in URL '
          'template, positional parameter is marked as bodyParam',
          todo: 'Ensure parameters always occur before the body parameter',
          element: method,
        );
      }

      if (!param.isRequired || param.type.isNullableType) {
        throw InvalidGenerationSource(
          'Path parameters cannot be optional nullable.',
          todo: 'Make parameter required and non nullable',
          element: param,
        );
      }

      if (pathParamMatches.isEmpty) {
        throw InvalidGenerationSource(
          'Unable to find parameter named ${param.name} in the URL template '
          'of the endpoint method',
          todo: 'Ensure parameters are correctly named in both URL and method.',
          element: param,
        );
      }

      final matchName = pathParamMatches.removeAt(0);
      if (matchName != param.name) {
        throw InvalidGenerationSource(
          'Expected ${param.name} in the URL template but found $matchName. '
          'Make sure template parameters and method parameters are in the same '
          'order!',
          todo: 'Reorder or rename your method parameters.',
          element: param,
        );
      }

      final pathParam = param.pathParamAnnotation;
      final paramType = param.type;
      yield EndpointPathParameter(
        name: param.name,
        type: OpaqueDartType(_buildStep, paramType),
        isString: paramType.isDartCoreString,
        isEnum: paramType.isEnum,
        isDateTime: TypeCheckers.dateTime.isExactlyType(paramType),
        customParse: await pathParam?.parse(_buildStep),
        customToString: await pathParam?.stringify(_buildStep),
        urlEncode: pathParam?.urlEncode ?? true,
      );
    }

    for (final match in pathParamMatches) {
      throw InvalidGenerationSource(
        'Found path parameter $match in URL template, but no matching '
        'method parameter was found.',
        todo: 'Ensure parameters are correctly named in both URL and method.',
        element: method,
      );
    }
  }
}
