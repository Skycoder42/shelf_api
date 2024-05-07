import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_response.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import '../common/from_json_builder.dart';

@internal
final class MethodBuilder extends SpecBuilder<Method> {
  static const _responseRef = Reference(r'$response');
  static const _optionsRef = Reference('options');
  static const _cancelTokenRef = Reference('cancelToken');
  static const _onSendProgressRef = Reference('onSendProgress');
  static const _onReceiveProgressRef = Reference('onReceiveProgress');

  final Endpoint _endpoint;
  final EndpointMethod _method;
  final Reference _dioRef;

  const MethodBuilder(this._endpoint, this._method, this._dioRef);

  @override
  Method build() => Method(
        (b) => b
          ..name = _methodName
          ..returns = _returnType
          ..modifier = _method.response.responseType.isStream
              ? MethodModifier.asyncStar
              : MethodModifier.async
          ..optionalParameters.addAll(_buildOptionalParameters())
          ..body = Block.of(_buildBody()),
      );

  String get _methodName {
    var name = _endpoint.name;
    name = name[0].toLowerCase() + name.substring(1);
    if (name.endsWith('Endpoint')) {
      name = name.substring(0, name.length - 8);
    }
    return name + _method.name.pascal;
  }

  TypeReference get _returnType {
    final response = _method.response;

    final innerType = switch (response.responseType) {
      EndpointResponseType.binary => Types.list(Types.int$),
      _ => Types.fromType(response.returnType),
    };

    if (response.responseType.isStream) {
      return innerType;
    } else {
      return Types.future(innerType);
    }
  }

  Iterable<Parameter> _buildOptionalParameters() sync* {
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

  Iterable<Code> _buildBody() sync* {
    final invocation = _dioRef.property('request').call(
      [
        _methodPath,
      ],
      {
        _optionsRef.symbol!: _optionsRef
            .ifNullThen(Types.options.newInstance(const []))
            .parenthesized
            .property('copyWith')
            .call(const [], _options),
        _cancelTokenRef.symbol!: _cancelTokenRef,
        _onSendProgressRef.symbol!: _onSendProgressRef,
        _onReceiveProgressRef.symbol!: _onReceiveProgressRef,
      },
      [
        _responseDartType,
      ],
    );

    yield declareFinal(_responseRef.symbol!)
        .assign(invocation.awaited)
        .statement;
  }

  Expression get _methodPath {
    final pathBuilder = StringBuffer();
    if (_endpoint.path case final String path) {
      pathBuilder.write(path);
      if (path.endsWith('/')) {
        pathBuilder.write(_method.path.substring(1));
      } else {
        pathBuilder.write(_method.path);
      }
    } else {
      pathBuilder.write(_method.path);
    }
    return literalString(pathBuilder.toString(), raw: true);
  }

  Map<String, Expression> get _options => {
        'method': literalString(_method.httpMethod),
        'responseType': _responseType,
      };

  TypeReference get _responseDartType {
    switch (_method.response.responseType) {
      case EndpointResponseType.noContent:
        return Types.void$;
      case EndpointResponseType.text:
        return Types.string;
      case EndpointResponseType.binary:
        return Types.list(Types.int$);
      case EndpointResponseType.textStream:
      case EndpointResponseType.binaryStream:
        return Types.responseBody;
      case EndpointResponseType.json:
        // TODO move logic into custom builder class
        final serializableType = _method.response.returnType.toSerializable(
          'EndpointResponse with responseType json must hold a '
          'OpaqueSerializableType',
        );
        return FromJsonBuilder(serializableType).rawJsonType;
    }
  }

  Expression get _responseType => switch (_method.response.responseType) {
        EndpointResponseType.noContent => literalNull,
        EndpointResponseType.text => Types.responseType.property('plain'),
        EndpointResponseType.binary => Types.responseType.property('bytes'),
        EndpointResponseType.textStream =>
          Types.responseType.property('stream'),
        EndpointResponseType.binaryStream =>
          Types.responseType.property('stream'),
        EndpointResponseType.json => Types.responseType.property('json'),
      };
}
