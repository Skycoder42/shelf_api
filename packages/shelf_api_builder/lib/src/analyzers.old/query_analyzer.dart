import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_query_parameter.dart';
import '../models/opaque_type.dart';

@internal
class QueryAnalyzer {
  const QueryAnalyzer();

  List<EndpointQueryParameter> analyzeQuery(
    MethodElement method,
    bool hasBodyParam,
  ) =>
      method.parameters.skip(hasBodyParam ? 1 : 0).map(_analyzeParam).toList();

  EndpointQueryParameter _analyzeParam(ParameterElement param) {
    if (param.isPositional) {
      throw InvalidGenerationSource(
        'Only named parameters can be used',
        element: param,
      );
    }

    if (param.type.isNullableType &&
        (param.isRequired || param.hasDefaultValue)) {
      throw InvalidGenerationSource(
        'Nullable parameters can neither be required nor have default values',
        element: param,
      );
    }

    return EndpointQueryParameter(
      name: param.name,
      type: OpaqueDartType(param.type),
      isString: param.type.isDartCoreString,
      isOptional: param.isOptional,
      defaultValue: param.defaultValueCode,
    );
  }
}
