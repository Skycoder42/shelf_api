import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_query_parameter.dart';
import '../models/opaque_type.dart';
import '../readers/query_param_reader.dart';
import '../util/type_checkers.dart';

@internal
class QueryAnalyzer {
  final BuildStep _buildStep;

  QueryAnalyzer(this._buildStep);

  Future<List<EndpointQueryParameter>> analyzeQuery(MethodElement method) =>
      _analyzeQuery(method).toList();

  Stream<EndpointQueryParameter> _analyzeQuery(MethodElement method) async* {
    for (final param in method.parameters) {
      if (param.isPositional) {
        continue;
      }

      yield await _analyzeParam(param);
    }
  }

  Future<EndpointQueryParameter> _analyzeParam(ParameterElement param) async {
    var paramType = param.type;
    if (paramType.isNullableType &&
        (param.isRequired || param.hasDefaultValue)) {
      throw InvalidGenerationSource(
        'Nullable query parameters can neither be required '
        'nor have default values',
        element: param,
      );
    }

    var isList = false;
    if (param.type.isDartCoreList) {
      isList = true;
      [paramType] = paramType.typeArgumentsOf(TypeCheckers.list)!;
      if (paramType.isNullableType) {
        throw InvalidGenerationSource(
          'Query parameters for list values cannot be nullable lists!',
          todo: 'Make list param type $paramType non nullable.',
          element: param,
        );
      }
    }

    final queryParam = param.queryParamAnnotation;
    return EndpointQueryParameter(
      paramName: param.name,
      queryName: queryParam?.name ?? param.name,
      type: OpaqueDartType(paramType),
      isString: paramType.isDartCoreString,
      isList: isList,
      isOptional: param.isOptional,
      defaultValue: param.defaultValueCode,
      customParse: await queryParam?.parse(_buildStep),
      customToString: await queryParam?.stringify(_buildStep),
    );
  }
}
