import 'dart:io';

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
import 'serializable_analyzer.dart';

@internal
class BodyAnalyzer {
  final BuildStep _buildStep;
  final SerializableAnalyzer _serializableAnalyzer;

  BodyAnalyzer(this._buildStep)
    : _serializableAnalyzer = SerializableAnalyzer(_buildStep);

  Future<EndpointBody?> analyzeBody(MethodElement method) async {
    final result = _findBodyParam(method);
    if (result == null) {
      return null;
    }
    final (param, bodyParam) = result;
    final paramType = param.type;

    if (_serializableAnalyzer.isCustom(bodyParam)) {
      return EndpointBody(
        paramType: await _serializableAnalyzer.analyzeType(
          param,
          param.type,
          bodyParam,
        ),
        bodyType: EndpointBodyType.json,
        contentTypes: bodyParam.contentTypes ?? [ContentType.json.mimeType],
      );
    } else if (paramType.isDartCoreString) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(_buildStep, param.type),
        bodyType: EndpointBodyType.text,
        contentTypes: bodyParam.contentTypes ?? const [],
      );
    } else if (TypeCheckers.uint8List.isAssignableFromType(paramType)) {
      _ensureNotNullable(paramType, method);
      return EndpointBody(
        paramType: OpaqueDartType(_buildStep, param.type),
        bodyType: EndpointBodyType.binary,
        contentTypes: bodyParam.contentTypes ?? const [],
      );
    } else if (paramType.isDartAsyncStream) {
      _ensureNotNullable(paramType, method);
      return _analyzeStreamBody(param, paramType, bodyParam);
    } else {
      return EndpointBody(
        paramType: await _serializableAnalyzer.analyzeType(
          param,
          param.type,
          bodyParam,
        ),
        bodyType: EndpointBodyType.json,
        contentTypes: bodyParam.contentTypes ?? [ContentType.json.mimeType],
      );
    }
  }

  (ParameterElement, BodyParamReader)? _findBodyParam(MethodElement method) {
    final lastParam = method.parameters.where((p) => p.isPositional).lastOrNull;

    for (final param in method.parameters) {
      if (param == lastParam) {
        continue;
      }

      if (param.bodyParamAnnotation != null) {
        throw InvalidGenerationSource(
          'Only the last positional parameter can be marked as body.',
          todo: 'Move the parameter to the end of the method',
          element: param,
        );
      }
    }

    if (lastParam == null) {
      return null;
    }

    final bodyParam = lastParam.bodyParamAnnotation;
    if (bodyParam == null) {
      return null;
    }

    if (!lastParam.isRequiredPositional) {
      throw InvalidGenerationSource(
        'The body parameter must be required positional.',
        todo: 'Turn the parameter into a non optional positional parameter',
        element: lastParam,
      );
    }

    return (lastParam, bodyParam);
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
    BodyParamReader bodyParam,
  ) {
    final [streamType] = paramType.typeArgumentsOf(TypeCheckers.stream)!;
    if (streamType.isDartCoreString && !streamType.isNullableType) {
      return EndpointBody(
        paramType: OpaqueDartType(_buildStep, param.type),
        bodyType: EndpointBodyType.textStream,
        contentTypes: bodyParam.contentTypes ?? const [],
      );
    } else if (TypeCheckers.uint8List.isAssignableFromType(streamType) &&
        !streamType.isNullableType) {
      return EndpointBody(
        paramType: OpaqueDartType(_buildStep, param.type),
        bodyType: EndpointBodyType.binaryStream,
        contentTypes: bodyParam.contentTypes ?? const [],
      );
    } else {
      throw InvalidGenerationSource(
        'Only Stream<String> or Stream<Uint8List> are supported as stream '
        'body types.',
        element: param,
      );
    }
  }
}
