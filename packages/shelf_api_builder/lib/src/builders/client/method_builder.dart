import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_body.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_response.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'method_body_builder.dart';

@internal
final class MethodBuilder extends SpecBuilder<Method> {
  static const _optionsRef = Reference(r'$options');
  static const _cancelTokenRef = Reference(r'$cancelToken');
  static const _onSendProgressRef = Reference(r'$onSendProgress');
  static const _onReceiveProgressRef = Reference(r'$onReceiveProgress');

  final ApiClass _apiClass;
  final Endpoint _endpoint;
  final EndpointMethod _method;
  final Reference _dioRef;

  const MethodBuilder(
    this._apiClass,
    this._endpoint,
    this._method,
    this._dioRef,
  );

  @override
  Method build() => Method(
    (b) => b
      ..name = _methodName
      ..returns = _returnType(false)
      ..modifier = _method.response.responseType.isStream
          ? MethodModifier.asyncStar
          : MethodModifier.async
      ..requiredParameters.addAll(_buildRequiredParameters())
      ..optionalParameters.addAll(_buildOptionalParameters())
      ..body = MethodBodyBuilder(
        _apiClass,
        _endpoint,
        _method,
        _dioRef,
        _optionsRef,
        [_cancelTokenRef, _onSendProgressRef, _onReceiveProgressRef],
        false,
      ),
  );

  Method buildRaw() => Method(
    (b) => b
      ..name = '${_methodName}Raw'
      ..returns = _returnType(true)
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll(_buildRequiredParameters())
      ..optionalParameters.addAll(_buildOptionalParameters())
      ..body = MethodBodyBuilder(
        _apiClass,
        _endpoint,
        _method,
        _dioRef,
        _optionsRef,
        [_cancelTokenRef, _onSendProgressRef, _onReceiveProgressRef],
        true,
      ),
  );

  String get _methodName {
    var name = _endpoint.name;
    name = name[0].toLowerCase() + name.substring(1);
    if (name.endsWith('Endpoint')) {
      name = name.substring(0, name.length - 8);
    }
    return name + _method.name.pascal;
  }

  TypeReference _returnType(bool isRaw) {
    final response = _method.response;

    final innerType = switch (response.responseType) {
      EndpointResponseType.binaryStream => Types.stream(Types.uint8List),
      EndpointResponseType.dynamic => Types.responseBody,
      _ => Types.fromType(response.returnType),
    };

    if (response.responseType.isStream) {
      return isRaw ? Types.future(Types.tResponseBody(innerType)) : innerType;
    } else {
      return isRaw
          ? Types.future(Types.tResponseBody(innerType))
          : Types.future(innerType);
    }
  }

  Iterable<Parameter> _buildRequiredParameters() sync* {
    for (final pathParam in _method.pathParameters) {
      yield Parameter(
        (b) => b
          ..name = pathParam.name
          ..type = Types.fromType(pathParam.type),
      );
    }
    if (_method.body case final EndpointBody body) {
      yield Parameter(
        (b) => b
          ..name = 'body'
          ..type = switch (body.bodyType) {
            EndpointBodyType.binaryStream => Types.stream(
              Types.list(Types.int$),
            ),
            _ => Types.fromType(body.paramType),
          },
      );
    }
  }

  Iterable<Parameter> _buildOptionalParameters() sync* {
    for (final queryParam in _method.queryParameters) {
      yield Parameter(
        (b) => b
          ..name = queryParam.paramName
          ..named = true
          ..required = !queryParam.isOptional
          ..type =
              (queryParam.isList
                      ? Types.list(Types.fromType(queryParam.type))
                      : Types.fromType(queryParam.type))
                  .withNullable(queryParam.isOptional),
      );
    }

    yield Parameter(
      (b) => b
        ..name = _optionsRef.symbol!
        ..named = true
        ..type = Types.options.withNullable(true),
    );
    yield Parameter(
      (b) => b
        ..name = _cancelTokenRef.symbol!
        ..named = true
        ..type = Types.cancelToken.withNullable(true),
    );
    yield Parameter(
      (b) => b
        ..name = _onSendProgressRef.symbol!
        ..named = true
        ..type = Types.progressCallback.withNullable(true),
    );
    yield Parameter(
      (b) => b
        ..name = _onReceiveProgressRef.symbol!
        ..named = true
        ..type = Types.progressCallback.withNullable(true),
    );
  }
}
