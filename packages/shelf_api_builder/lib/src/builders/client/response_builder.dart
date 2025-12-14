import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_response.dart';
import '../../util/code/if.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';
import '../common/from_json_builder.dart';

@internal
final class ResponseBuilder extends CodeBuilder {
  static const _responseRef = Reference(r'$response');
  static const _responseDataRef = Reference(r'$responseData');

  final EndpointResponse _response;
  final Expression _invocation;
  final bool _isRaw;

  // ignore: avoid_positional_boolean_parameters for private param
  const ResponseBuilder(this._response, this._invocation, this._isRaw);

  @override
  Iterable<Code> build() sync* {
    if (!_isRaw && _response.responseType == EndpointResponseType.noContent) {
      yield _invocation.statement;
    } else {
      yield declareFinal(_responseRef.symbol!).assign(_invocation).statement;
    }

    switch (_response.responseType) {
      case EndpointResponseType.noContent:
        if (_isRaw) {
          yield _returned(literalNull);
        }
      case EndpointResponseType.text:
        yield _returned(
          _responseRef.property('data').ifNullThen(literalString('')),
        );
      case EndpointResponseType.binary:
        yield _returned(
          _responseRef
              .property('data')
              .ifNullThen(Types.uint8List.newInstance([literalNum(0)])),
        );
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
      case EndpointResponseType.dynamic:
        yield _returned(_responseRef.property('data').nullChecked);
    }
  }

  Code _buildStreamReturn([
    Expression Function(Expression stream) transform = _transformNoop,
  ]) {
    final transformedStream = transform(
      _responseRef.property('data').nullChecked.property('stream'),
    );
    return _isRaw
        ? _returned(transformedStream)
        : transformedStream.yieldedStar.statement;
  }

  Iterable<Code> _buildJsonReturn() sync* {
    yield declareFinal(
      _responseDataRef.symbol!,
    ).assign(_responseRef.property('data')).statement;

    final serializableType = _response.serializableReturnType;
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
    yield _returned(fromJsonBuilder.buildFromJson(_responseDataRef));
  }

  Code _returned(Expression expression) => _isRaw
      ? Types.tResponseBody()
            .newInstanceNamed('fromResponse', [_responseRef, expression])
            .returned
            .statement
      : expression.returned.statement;

  static Expression _transformNoop(Expression expr) => expr;
}
