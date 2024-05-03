import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_body.dart';
import '../models/opaque_type.dart';
import '../readers/body_param_reader.dart';
import '../util/type_checkers.dart';

@internal
class BodyAnalyzer {
  final BuildStep _buildStep;

  BodyAnalyzer(this._buildStep);

  Future<EndpointBody?> analyzeBody(MethodElement method) async {
    final result = _findBodyParam(method);
    if (result == null) {
      return null;
    }
    final (param, bodyParam) = result;
    final paramType = param.type;

    if (bodyParam.hasFromJson) {
      return EndpointBody(
        paramType: OpaqueDartType(paramType),
        bodyType: EndpointBodyType.json,
        fromJson: await bodyParam.fromJson(_buildStep),
        isNullable: paramType.isNullableType,
      );
    } else if (paramType.isDartCoreString) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(param.type),
        bodyType: EndpointBodyType.text,
      );
    } else if (TypeCheckers.uint8List.isAssignableFrom(paramType.element!)) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(param.type),
        bodyType: EndpointBodyType.binary,
      );
    } else if (paramType.isDartAsyncStream) {
      _ensureNotNullable(paramType, method);
      return _analyzeStreamBody(param, paramType);
    } else if (paramType.isDartCoreList) {
      return _analyzeJsonList(param, paramType);
    } else if (paramType.isDartCoreMap) {
      return _analyzeJsonMap(param, paramType);
    } else {
      return EndpointBody(
        paramType: OpaqueDartType(paramType),
        bodyType: EndpointBodyType.json,
        jsonType: _fromJsonType(param, paramType),
        isNullable: paramType.isNullableType,
      );
    }
  }

  (ParameterElement, BodyParamReader)? _findBodyParam(MethodElement method) {
    for (final param in method.parameters.skip(1)) {
      if (param.bodyParamAnnotation != null) {
        throw InvalidGenerationSource(
          'Only the first parameter can be marked as body.',
          todo: 'Move the parameter to the beginning of the method',
          element: param,
        );
      }
    }

    final firstParam = method.parameters.firstOrNull;
    if (firstParam == null) {
      return null;
    }

    final bodyParam = firstParam.bodyParamAnnotation;
    if (bodyParam == null) {
      return null;
    }

    if (!firstParam.isRequiredPositional) {
      throw InvalidGenerationSource(
        'The body parameter must be required positional.',
        todo: 'Turn the parameter into a non optional positional parameter',
        element: firstParam,
      );
    }

    return (firstParam, bodyParam);
  }

  void _ensureNotNullable(DartType paramType, MethodElement method) {
    if (paramType.isNullableType) {
      throw InvalidGenerationSource(
        '$paramType body cannot be nullable!',
        todo: 'Make the type non nullable.',
        element: method,
      );
    }
  }

  EndpointBody _analyzeStreamBody(
    ParameterElement param,
    DartType paramType,
  ) {
    final [streamType] = paramType.typeArgumentsOf(TypeCheckers.stream)!;
    if (streamType.isDartCoreString && !streamType.isNullableType) {
      return EndpointBody(
        paramType: OpaqueDartType(param.type),
        bodyType: EndpointBodyType.textStream,
        isNullable: paramType.isNullableType,
      );
    } else if (TypeCheckers.intList.isExactly(streamType.element!) &&
        !streamType.isNullableType) {
      return EndpointBody(
        paramType: OpaqueDartType(param.type),
        bodyType: EndpointBodyType.binaryStream,
        isNullable: paramType.isNullableType,
      );
    } else {
      throw InvalidGenerationSource(
        'Only Stream<String> or Stream<List<int>> are supported as stream '
        'body types.',
        element: param,
      );
    }
  }

  EndpointBody _analyzeJsonList(
    ParameterElement param,
    DartType paramType,
  ) {
    final [listType] = paramType.typeArgumentsOf(TypeCheckers.list)!;
    if (listType.isNullableType) {
      throw InvalidGenerationSource(
        'List type must not be nullable!',
        todo: 'Make list type non nullable or use the "fromJson" parameter '
            'of the BodyParam annotation to specify a custom converter.',
        element: param,
      );
    }

    return EndpointBody(
      paramType: OpaqueDartType(listType),
      bodyType: EndpointBodyType.jsonList,
      isNullable: paramType.isNullableType,
      jsonType: _fromJsonType(param, listType),
    );
  }

  EndpointBody _analyzeJsonMap(
    ParameterElement param,
    DartType paramType,
  ) {
    final [keyType, valueType] = paramType.typeArgumentsOf(TypeCheckers.map)!;
    if (!keyType.isDartCoreString) {
      throw InvalidGenerationSource(
        'Can only handle maps with a String keys',
        todo: 'Use the "fromJson" parameter of the BodyParam '
            'annotation to specify a custom converter or use string keys.',
        element: param,
      );
    }
    if (valueType.isNullableType) {
      throw InvalidGenerationSource(
        'Map value type must not be nullable!',
        todo: 'Make map value type non nullable or use the "fromJson" '
            'parameter of the BodyParam annotation to specify a custom '
            'converter.',
        element: param,
      );
    }

    return EndpointBody(
      paramType: OpaqueDartType(valueType),
      bodyType: EndpointBodyType.jsonMap,
      isNullable: paramType.isNullableType,
      jsonType: _fromJsonType(param, valueType),
    );
  }

  OpaqueType? _fromJsonType(
    ParameterElement param,
    DartType paramType,
  ) {
    if (paramType.isDartCoreBool ||
        paramType.isDartCoreDouble ||
        paramType.isDartCoreInt ||
        paramType.isDartCoreNum ||
        paramType.isDartCoreNull) {
      return null;
    }

    final element = paramType.element;
    if (element is! ClassElement) {
      throw InvalidGenerationSource(
        'Cannot generate body for type without a fromJson constructor!',
        todo: 'Use the "fromJson" parameter of the BodyParam '
            'annotation to specify a custom converter.',
        element: param,
      );
    }

    final fromJson =
        element.constructors.where((c) => c.name == 'fromJson').singleOrNull;
    if (fromJson == null) {
      throw InvalidGenerationSource(
        'Cannot generate body for type without a fromJson constructor!',
        todo: 'Use the "fromJson" parameter of the BodyParam '
            'annotation to specify a custom converter.',
        element: param,
      );
    }

    final firstParam = fromJson.parameters.firstOrNull;
    if (firstParam == null || !firstParam.isPositional) {
      throw InvalidGenerationSource(
        'fromJson constructor must have a single positional parameter!',
        todo: 'Use the "fromJson" parameter of the BodyParam '
            'annotation to specify a custom converter or adjust the fromJson.',
        element: param,
      );
    }

    return OpaqueDartType(firstParam.type);
  }
}
