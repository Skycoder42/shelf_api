import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/endpoint_response.dart';
import '../util/constants.dart';
import '../util/types.dart';
import 'base/code_builder.dart';

@internal
final class ResponseBuilder extends CodeBuilder {
  final EndpointResponse _response;
  final Expression _invocation;

  const ResponseBuilder(this._response, this._invocation);

  @override
  Iterable<Code> build() sync* {
    switch (_response.responseType) {
      case EndpointResponseType.noContent:
        yield _invocation.statement;
        yield Types.response
            .newInstance([Types.httpStatus.property('noContent')])
            .returned
            .statement;
      case EndpointResponseType.text:
        yield Types.response
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.binary:
        yield Types.response
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.textStream:
        yield Types.response
            .newInstanceNamed('ok', [
              _invocation
                  .property('transform')
                  .call([Constants.utf8.property('encoder')]),
            ], {
              'encoding': Constants.utf8,
            })
            .returned
            .statement;
      case EndpointResponseType.binaryStream:
        yield Types.response
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.json:
        yield Types.response
            .newInstanceNamed('ok', [
              Constants.json.property('encode').call([_invocation]),
            ])
            .returned
            .statement;
      case EndpointResponseType.response:
        yield _invocation.returned.statement;
    }
  }
}
