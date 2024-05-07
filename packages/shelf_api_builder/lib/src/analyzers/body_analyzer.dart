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
  final SerializableAnalyzer _serializableAnalyzer;

  BodyAnalyzer(BuildStep buildStep)
      : _serializableAnalyzer = SerializableAnalyzer(buildStep);

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
    } else {
      return EndpointBody(
        paramType: await _serializableAnalyzer.analyzeType(
          param,
          param.type,
          bodyParam,
        ),
        bodyType: EndpointBodyType.json,
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
      );
    } else if (TypeCheckers.intList.isExactly(streamType.element!) &&
        !streamType.isNullableType) {
      return EndpointBody(
        paramType: OpaqueDartType(param.type),
        bodyType: EndpointBodyType.binaryStream,
      );
    } else {
      throw InvalidGenerationSource(
        'Only Stream<String> or Stream<List<int>> are supported as stream '
        'body types.',
        element: param,
      );
    }
  }
}
