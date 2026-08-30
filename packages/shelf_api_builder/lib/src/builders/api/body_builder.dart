import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
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

  const new(this._methodBody, this._requestRef);

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

  const new(this._methodBody, this._requestRef);

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
            .call(const [], const {}, [CoreTypes.$List(CoreTypes.$int)])
            .property('transform')
            .call([Constants.utf8.property('decoder')]);
      case EndpointBodyType.binaryStream:
        bodyExpr = _requestRef
            .property('read')
            .call(const [])
            .asA(Types.stream(Types.uint8List));
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

    yield Conditional(
      (b) => b
        ..branches.add(
          Branch(
            (b) => b
              ..condition = .expression(
                literalConstList(_methodBody.contentTypes)
                    .property('contains')
                    .call([_requestRef.property('mimeType')])
                    .negate(),
              )
              ..body = Types.shelfResponse
                  .newInstance(
                    [literalNum(HttpStatus.unsupportedMediaType)],
                    {
                      'body': LiteralString(
                        (b) => b
                          ..addString(
                            'Expected content type to be any of '
                            // ignore: lines_longer_than_80_chars for readability
                            '${_methodBody.contentTypes.map((e) => '"$e"').join(', ')} '
                            'but was "',
                          )
                          ..addParameter(_requestRef.property('mimeType'))
                          ..addString('"'),
                      ),
                    },
                  )
                  .returned
                  .statement,
          ),
        ),
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
      yield Conditional(
        (b) => b
          ..branches.add(
            Branch(
              (b) => b
                ..condition = .expression(_rawBodyRef.property('isEmpty'))
                ..body = Types.shelfResponse
                    .newInstanceNamed('badRequest', const [], {
                      'body': literalString('Missing required request body'),
                    })
                    .returned
                    .statement,
            ),
          ),
      );
      callExpr = Constants.json.property('decode').call(const [_rawBodyRef]);
    }

    yield declareFinal(BodyBuilder._bodyRef.symbol!)
        .assign(
          rawJsonType == CoreTypes.$dynamic
              ? callExpr
              : callExpr.asA(rawJsonType),
        )
        .statement;
  }
}

final class _BodyParamBuilder extends ExpressionBuilder {
  final EndpointBody _methodBody;

  const new(this._methodBody);

  @override
  Expression build() {
    if (_methodBody.bodyType != EndpointBodyType.json) {
      return BodyBuilder._bodyRef;
    }

    return FromJsonBuilder(_methodBody.serializableParamType)
        .buildFromJson(BodyBuilder._bodyRef);
  }
}
