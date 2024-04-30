import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/endpoint_body.dart';
import '../models/opaque_type.dart';
import '../util/type_checkers.dart';

@internal
class BodyAnalyzer {
  const BodyAnalyzer();

  EndpointBody? analyzeBody(MethodElement method) {
    // TODO use fromJson in annotation

    final bodyParam = method.parameters.firstOrNull;
    if (bodyParam == null || !bodyParam.isRequiredPositional) {
      return null;
    }

    final paramType = bodyParam.type;
    if (paramType.isDartCoreString) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(bodyParam.type),
        bodyType: EndpointBodyType.text,
      );
    } else if (TypeCheckers.uint8List.isAssignableFrom(paramType.element!)) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(bodyParam.type),
        bodyType: EndpointBodyType.binary,
      );
    } else if (TypeCheckers.formData.isExactly(paramType.element!)) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(bodyParam.type),
        bodyType: EndpointBodyType.formData,
        isNullable: paramType.isNullableType,
      );
    } else if (paramType.isDartAsyncStream) {
      _ensureNotNullable(paramType, method);
      return _analyzeStreamBody(bodyParam, paramType);
    } else if (paramType.isDartCoreList) {
      return _analyzeJsonList(bodyParam, paramType);
    } else if (paramType.isDartCoreMap) {
      return _analyzeJsonMap(bodyParam, paramType);
    } else {
      return EndpointBody(
        paramType: OpaqueDartType(paramType),
        bodyType: EndpointBodyType.json,
        jsonType: _fromJsonType(bodyParam, paramType),
        isNullable: paramType.isNullableType,
      );
    }
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
        todo: 'Make list type non nullable or use the "bodyFromJson" parameter '
            'of the FrogEndpoint annotation to specify a custom converter.',
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
        todo: 'Use the "bodyFromJson" parameter of the FrogEndpoint '
            'annotation to specify a custom converter or use string keys.',
        element: param,
      );
    }
    if (valueType.isNullableType) {
      throw InvalidGenerationSource(
        'Map value type must not be nullable!',
        todo: 'Make map value type non nullable or use the "bodyFromJson" '
            'parameter of the FrogEndpoint annotation to specify a custom '
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
        todo: 'Use the "bodyFromJson" parameter of the FrogEndpoint '
            'annotation to specify a custom converter.',
        element: param,
      );
    }

    final fromJson =
        element.constructors.where((c) => c.name == 'fromJson').singleOrNull;
    if (fromJson == null) {
      throw InvalidGenerationSource(
        'Cannot generate body for type without a fromJson constructor!',
        todo: 'Use the "bodyFromJson" parameter of the FrogEndpoint '
            'annotation to specify a custom converter.',
        element: param,
      );
    }

    final firstParam = fromJson.parameters.firstOrNull;
    if (firstParam == null || !firstParam.isPositional) {
      throw InvalidGenerationSource(
        'fromJson constructor must have a single positional parameter!',
        todo: 'Use the "bodyFromJson" parameter of the FrogEndpoint '
            'annotation to specify a custom converter or adjust the fromJson.',
        element: param,
      );
    }

    return OpaqueDartType(firstParam.type);
  }
}
