import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
import '../../util/code/if.dart';
import '../../util/code/literal_string_builder.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';
import '../base/expression_builder.dart';
import '../common/from_json_builder.dart';

@internal
final class BodyBuilder {
  static const _bodyRef = Reference(r'$body');

  final EndpointBody? _methodBody;
  final Reference _requestRef;

  const BodyBuilder(this._methodBody, this._requestRef);

  Code get variables => _methodBody != null
      ? _BodyVariableBuilder(_methodBody, _requestRef)
      : const Code('');

  Expression? get parameter =>
      _methodBody != null ? _BodyParamBuilder(_methodBody) : null;
}

final class _BodyVariableBuilder extends CodeBuilder {
  static const _rawBodyRef = Reference(r'$rawBody');

  final EndpointBody _methodBody;
  final Reference _requestRef;

  const _BodyVariableBuilder(this._methodBody, this._requestRef);

  @override
  Iterable<Code> build() sync* {
    yield* _validateContentType();

    final Expression bodyExpr;
    switch (_methodBody.bodyType) {
      case EndpointBodyType.text:
        bodyExpr = _requestRef.property('readAsString').call(const []).awaited;
      case EndpointBodyType.binary:
        bodyExpr = _requestRef
            .property('read')
            .call(const [])
            .property('collect')
            .call([_requestRef])
            .awaited;
      case EndpointBodyType.textStream:
        bodyExpr = _requestRef
            .property('read')
            .call(const [])
            .property('cast')
            .call(const [], const {}, [Types.list(Types.int$)])
            .property('transform')
            .call([Constants.utf8.property('decoder')]);
      case EndpointBodyType.binaryStream:
        bodyExpr = _requestRef
            .property('read')
            .call(const []).asA(Types.stream(Types.uint8List));
      case EndpointBodyType.json:
        yield* _jsonCall();
        return;
    }

    yield declareFinal(BodyBuilder._bodyRef.symbol!).assign(bodyExpr).statement;
  }

  Iterable<Code> _validateContentType() sync* {
    if (_methodBody.contentTypes.isEmpty) {
      return;
    }

    yield If(
      literalConstList(_methodBody.contentTypes)
          .property('contains')
          .call([_requestRef.property('mimeType')]).negate(),
      Types.shelfResponse
          .newInstance([
            literalNum(HttpStatus.unsupportedMediaType),
          ], {
            'body': LiteralStringBuilder()
              ..addTemplate(
                'Expected content type to be any of '
                '${_methodBody.contentTypes.map((e) => '"$e"').join(', ')} '
                'but was "%type%"',
                {'%type%': _requestRef.property('mimeType')},
              ),
          })
          .returned
          .statement,
    );
  }

  Iterable<Code> _jsonCall() sync* {
    yield declareFinal(_rawBodyRef.symbol!)
        .assign(_requestRef.property('readAsString').call(const []).awaited)
        .statement;

    final serializableType = _methodBody.serializableParamType;
    final rawJsonType = FromJsonBuilder(serializableType).rawJsonType;

    final Expression callExpr;
    if (serializableType.isNullable) {
      callExpr = _rawBodyRef
          .property('isNotEmpty')
          .conditional(
            Constants.json.property('decode').call(const [_rawBodyRef]),
            literalNull,
          )
          .parenthesized;
    } else {
      yield If(
        _rawBodyRef.property('isEmpty'),
        Types.shelfResponse
            .newInstanceNamed('badRequest', const [], {
              'body': literalString('Missing required request body'),
            })
            .returned
            .statement,
      );
      callExpr = Constants.json.property('decode').call(const [_rawBodyRef]);
    }

    yield declareFinal(BodyBuilder._bodyRef.symbol!)
        .assign(
          rawJsonType == Types.dynamic$ ? callExpr : callExpr.asA(rawJsonType),
        )
        .statement;
  }
}

final class _BodyParamBuilder extends ExpressionBuilder {
  final EndpointBody _methodBody;

  const _BodyParamBuilder(this._methodBody);

  @override
  Expression build() {
    if (_methodBody.bodyType != EndpointBodyType.json) {
      return BodyBuilder._bodyRef;
    }

    return FromJsonBuilder(_methodBody.serializableParamType)
        .buildFromJson(BodyBuilder._bodyRef);
  }
}
