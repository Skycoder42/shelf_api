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

@internal
class PathAnalyzer {
  final _pathParamRegexp = RegExp(r'^<(\w+)(?:\|.+?)?>$');

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
    final pathParamMatches = apiMethod.path
        .split('/')
        .map(_pathParamRegexp.firstMatch)
        .whereType<RegExpMatch>()
        .map((match) => match[1]!)
        .toList();

    final positionalParams = method.parameters
        .where((p) => p.isPositional)
        .where((p) => p.bodyParamAnnotation == null);

    for (final param in positionalParams) {
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
      yield EndpointPathParameter(
        name: param.name,
        type: OpaqueDartType(_buildStep, param.type),
        isString: param.type.isDartCoreString,
        customParse: await pathParam?.parse(_buildStep),
        customToString: await pathParam?.stringify(_buildStep),
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
