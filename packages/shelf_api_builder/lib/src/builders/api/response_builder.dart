import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_response.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';

@internal
final class ResponseBuilder extends CodeBuilder {
  final EndpointResponse _response;
  final Expression _invocation;

  const ResponseBuilder(this._response, this._invocation);

  @override
  Iterable<Code> build() sync* {
    // TODO set correct content type header!
    switch (_response.responseType) {
      case EndpointResponseType.noContent:
        yield _invocation.statement;
        yield Types.shelfResponse
            .newInstance([Types.httpStatus.property('noContent')])
            .returned
            .statement;
      case EndpointResponseType.text:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.binary:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.textStream:
        yield Types.shelfResponse
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
        yield Types.shelfResponse
            .newInstanceNamed('ok', [_invocation])
            .returned
            .statement;
      case EndpointResponseType.json:
        yield Types.shelfResponse
            .newInstanceNamed('ok', [
              Constants.json.property('encode').call([
                if (_response.toJson case final OpaqueConstant toJson)
                  Constants.fromConstant(toJson).call([_invocation])
                else
                  _invocation,
              ]),
            ])
            .returned
            .statement;
      case EndpointResponseType.response:
        yield _invocation.returned.statement;
    }
  }
}
