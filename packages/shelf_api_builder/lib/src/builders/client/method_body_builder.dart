import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_body.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_response.dart';
import '../../util/code/if.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';
import '../common/from_json_builder.dart';

@internal
final class MethodBodyBuilder extends CodeBuilder {
  static const _responseRef = Reference(r'$response');
  static const _responseDataRef = Reference(r'$responseData');

  final ApiClass _apiClass;
  final Endpoint _endpoint;
  final EndpointMethod _method;
  final Reference _dioRef;
  final Reference _optionsRef;
  final List<Reference> _extraParamsRefs;

  const MethodBodyBuilder(
    this._apiClass,
    this._endpoint,
    this._method,
    this._dioRef,
    this._optionsRef,
    this._extraParamsRefs,
  );

  @override
  Iterable<Code> build() sync* {
    final invocation = _dioRef.property('request').call(
      [
        _methodPath,
      ],
      {
        if (_method.body case final EndpointBody body) 'body': literalNull,
        _optionsRef.symbol!: _optionsRef
            .ifNullThen(Types.options.newInstance(const []))
            .parenthesized
            .property('copyWith')
            .call(const [], _options),
        for (final param in _extraParamsRefs) param.symbol!: param,
      },
      [
        _responseDartType,
      ],
    );

    if (_method.response.responseType == EndpointResponseType.noContent) {
      yield invocation.awaited.statement;
    } else {
      yield declareFinal(_responseRef.symbol!)
          .assign(invocation.awaited)
          .statement;
    }

    switch (_method.response.responseType) {
      case EndpointResponseType.noContent:
        // nothing else to do
        break;
      case EndpointResponseType.text:
        yield _responseRef
            .property('data')
            .ifNullThen(literalString(''))
            .returned
            .statement;
      case EndpointResponseType.binary:
        yield _responseRef
            .property('data')
            .ifNullThen(literalConstList([]))
            .returned
            .statement;
      case EndpointResponseType.textStream:
        yield _buildStreamReturn(
          (stream) => stream
              .property('cast')
              .call(const [], const {}, [Types.list(Types.int$)])
              .property('transform')
              .call([Constants.utf8.property('decoder')]),
        );
      case EndpointResponseType.binaryStream:
        yield _buildStreamReturn();
      case EndpointResponseType.json:
        yield* _buildJsonReturn();
    }
  }

  Expression get _methodPath {
    final pathBuilder = StringBuffer();
    var hasTrailingSlash = false;

    if (_apiClass.basePath case final String path) {
      pathBuilder.write(path);
      hasTrailingSlash = path.endsWith('/');
    }

    if (_endpoint.path case final String path) {
      pathBuilder.write(hasTrailingSlash ? path.substring(1) : path);
      hasTrailingSlash = path.endsWith('/');
    }

    pathBuilder.write(
      hasTrailingSlash ? _method.path.substring(1) : _method.path,
    );

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
        return FromJsonBuilder(_method.response.serializableReturnType)
            .rawJsonType;
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

  Code _buildStreamReturn([
    Expression Function(Expression stream) transform = _transformNoop,
  ]) =>
      transform(_responseRef.property('data').nullChecked.property('stream'))
          .yieldedStar
          .statement;

  Iterable<Code> _buildJsonReturn() sync* {
    yield declareFinal(_responseDataRef.symbol!)
        .assign(_responseRef.property('data'))
        .statement;

    final serializableType = _method.response.serializableReturnType;
    if (!serializableType.isNullable) {
      yield If(
        _responseDataRef.equalTo(literalNull),
        Types.dioException
            .newInstance(const [], {
              'requestOptions': _responseRef.property('requestOptions'),
              'response': _responseRef,
              'type': Types.dioExceptionType.property('badResponse'),
              'message': literalString(
                'Received JSON response with null body, but empty responses '
                'are not allowed!',
              ),
            })
            .thrown
            .statement,
      );
    }

    final fromJsonBuilder = FromJsonBuilder(serializableType);
    yield fromJsonBuilder.buildFromJson(_responseDataRef).returned.statement;
  }

  static Expression _transformNoop(Expression expr) => expr;
}
