import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_response.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';

@internal
final class ResponseBuilder extends CodeBuilder {
  static const _responseRef = Reference(r'$response');

  final EndpointResponse _response;
  final Expression _invocation;

  const ResponseBuilder(this._response, this._invocation);

  @override
  Iterable<Code> build() sync* {
    if (_response.isResponse) {
      yield _invocation.returned.statement;
      return;
    }

    switch (_response.responseType) {
      case EndpointResponseType.noContent:
        yield _invocation.statement;
        yield Types.shelfResponse
            .newInstance([Types.httpStatus.property('noContent')])
            .returned
            .statement;
      case EndpointResponseType.text:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation], _extraParams('text'))
            .returned
            .statement;
      case EndpointResponseType.binary:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation], _extraParams('binary'))
            .returned
            .statement;
      case EndpointResponseType.textStream:
        yield Types.shelfResponse
            .newInstanceNamed(
              'ok',
              [
                _invocation
                    .property('transform')
                    .call([Constants.utf8.property('encoder')]),
              ],
              _extraParams('text', Constants.utf8),
            )
            .returned
            .statement;
      case EndpointResponseType.binaryStream:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation], _extraParams('binary'))
            .returned
            .statement;
      case EndpointResponseType.json:
        yield* _buildJson();
    }
  }

  Iterable<Code> _buildJson() sync* {
    final serializableType = _response.serializableReturnType;

    Expression responseExpr;
    if (serializableType.toJson case final OpaqueConstant toJson) {
      if (serializableType.isNullable) {
        yield declareFinal(_responseRef.symbol!).assign(_invocation).statement;
        responseExpr = _responseRef.notEqualTo(literalNull).conditional(
              Constants.fromConstant(toJson).call([_responseRef]),
              literalNull,
            );
      } else {
        responseExpr = Constants.fromConstant(toJson).call([_invocation]);
      }
    } else {
      responseExpr = _invocation;
    }

    yield Types.shelfResponse
        .newInstanceNamed(
          'ok',
          [
            Constants.json.property('encode').call([responseExpr]),
          ],
          _extraParams('json'),
        )
        .returned
        .statement;
  }

  Map<String, Expression> _extraParams(
    String typeName, [
    Reference? encoding,
  ]) =>
      {
        'headers': literalMap({
          Types.httpHeaders.property('contentTypeHeader'): Types.contentType
              .property(typeName)
              .property('toString')
              .call(const []),
        }),
        if (encoding != null) 'encoding': encoding,
      };
}
