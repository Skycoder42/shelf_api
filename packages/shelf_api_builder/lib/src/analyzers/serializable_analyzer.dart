import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import '../models/opaque_type.dart';
import '../models/serializable_type.dart';
import '../readers/serializable_reader.dart';
import '../util/type_checkers.dart';

@internal
class SerializableAnalyzer {
  final BuildStep _buildStep;

  SerializableAnalyzer(this._buildStep);

  bool isCustom(SerializableReader serializable) =>
      serializable.hasFromJson || serializable.hasToJson;

  Future<OpaqueSerializableType> analyzeType(
    Element element,
    DartType type,
    SerializableReader serializable,
  ) async =>
      OpaqueSerializableType(await _analyzeType(element, type, serializable));

  Future<SerializableType> _analyzeType(
    Element element,
    DartType type,
    SerializableReader serializable,
  ) async {
    if (isCustom(serializable)) {
      return SerializableType(
        dartType: OpaqueDartType(type),
        wrapped: Wrapped.none,
        isNullable: type.isNullableType,
        jsonType: _jsonType(element, type, serializable),
        fromJson: await serializable.fromJson(_buildStep),
        toJson: await serializable.toJson(_buildStep),
      );
    } else if (type.isDartCoreList) {
      return await _analyzeJsonList(element, type, serializable);
    } else if (type.isDartCoreMap) {
      return await _analyzeJsonMap(element, type, serializable);
    } else {
      return SerializableType(
        dartType: OpaqueDartType(type),
        wrapped: Wrapped.none,
        isNullable: type.isNullableType,
        jsonType: _jsonType(element, type, serializable),
      );
    }
  }

  Future<SerializableType> _analyzeJsonList(
    Element element,
    DartType type,
    SerializableReader serializable,
  ) async {
    final [listType] = type.typeArgumentsOf(TypeCheckers.list)!;
    if (listType.isNullableType && listType is! DynamicType) {
      throw InvalidGenerationSource(
        'List type must not be nullable!',
        todo: 'Make list type non nullable or use the "fromJson" parameter '
            'of the annotation to specify a custom converter.',
        element: element,
      );
    }

    return SerializableType(
      dartType: OpaqueDartType(listType),
      wrapped: Wrapped.list,
      isNullable: type.isNullableType,
      jsonType: _jsonType(element, listType, serializable),
    );
  }

  Future<SerializableType> _analyzeJsonMap(
    Element element,
    DartType type,
    SerializableReader serializable,
  ) async {
    final [keyType, valueType] = type.typeArgumentsOf(TypeCheckers.map)!;
    if (!keyType.isDartCoreString) {
      throw InvalidGenerationSource(
        'Can only handle maps with a String keys',
        todo: 'Use the "fromJson" parameter of the annotation to specify a '
            'custom converter or use string keys.',
        element: element,
      );
    }
    if (valueType.isNullableType && valueType is! DynamicType) {
      throw InvalidGenerationSource(
        'Map value type must not be nullable!',
        todo: 'Make map value type non nullable or use the "fromJson" '
            'parameter of the annotation to specify a custom converter.',
        element: element,
      );
    }

    return SerializableType(
      dartType: OpaqueDartType(valueType),
      wrapped: Wrapped.map,
      isNullable: type.isNullableType,
      jsonType: _jsonType(element, valueType, serializable),
    );
  }

  OpaqueType? _jsonType(
    Element element,
    DartType type,
    SerializableReader serializable,
  ) {
    if (type is DynamicType ||
        type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isDartCoreNum ||
        type.isDartCoreNull) {
      return null;
    }

    if (serializable.hasFromJson) {
      return null;
    }

    final typeElement = type.element;
    if (typeElement is! ClassElement) {
      throw InvalidGenerationSource(
        'Cannot generate conversion for type without a fromJson constructor!',
        todo: 'Use the "fromJson" parameter of the annotation to specify a '
            'custom converter.',
        element: element,
      );
    }

    final fromJson = typeElement.constructors
        .where((c) => c.name == 'fromJson')
        .singleOrNull;
    if (fromJson == null) {
      throw InvalidGenerationSource(
        'Cannot generate conversion for type without a fromJson constructor!',
        todo: 'Use the "fromJson" parameter of the annotation to specify a '
            'custom converter.',
        element: element,
      );
    }

    final firstParam = fromJson.parameters.firstOrNull;
    if (firstParam == null || !firstParam.isPositional) {
      throw InvalidGenerationSource(
        'fromJson constructor must have a single positional parameter!',
        todo: 'Use the "fromJson" parameter of the annotation to specify a '
            'custom converter or adjust the fromJson.',
        element: element,
      );
    }

    return OpaqueDartType(firstParam.type);
  }
}
