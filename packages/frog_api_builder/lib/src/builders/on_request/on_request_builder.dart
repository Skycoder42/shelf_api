import 'package:code_builder/code_builder.dart' hide MethodBuilder;
import 'package:meta/meta.dart';

import '../../models/endpoint.dart';
import '../../util/code/switch.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'method_builder.dart';

@internal
final class OnRequestBuilder extends SpecBuilder<Method> {
  static const _contextRef = Reference(r'$context');
  static const _endpointRef = Reference(r'$endpoint');

  final Endpoint _endpoint;

  const OnRequestBuilder(this._endpoint);

  @override
  Method build() => Method(
        (b) => b
          ..name = 'onRequest'
          ..modifier = _endpoint.isAsync ? MethodModifier.async : null
          ..returns =
              _endpoint.isAsync ? Types.future(Types.response) : Types.response
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = _contextRef.symbol!
                ..type = Types.requestContext,
            ),
          )
          ..requiredParameters.addAll(
            _endpoint.pathParameters.map(
              (p) => Parameter(
                (b) => b
                  ..name = p.name
                  ..type = Types.string,
              ),
            ),
          )
          ..body = Block.of(_buildBody()),
      );

  Iterable<Code> _buildBody() sync* {
    if (_endpoint.methods.isEmpty) {
      yield Types.response
          .newInstance(const [], {
            'statusCode': Types.httpStatus.property('notImplemented'),
          })
          .returned
          .statement;
      return;
    }

    yield declareFinal(_endpointRef.symbol!)
        .assign(
          Types.fromType(_endpoint.endpointType).newInstance([_contextRef]),
        )
        .statement;

    final switchCase =
        Switch(_contextRef.property('request').property('method'))
          ..defaultCase = Types.response
              .newInstance(const [], {
                'statusCode': Types.httpStatus.property('methodNotAllowed'),
              })
              .returned
              .statement;

    for (final MapEntry(key: httpMethod, value: endpointMethod)
        in _endpoint.methods.entries) {
      switchCase.addCase(
        Types.httpMethod.property(httpMethod.name),
        MethodBuilder(endpointMethod, _contextRef, _endpointRef),
      );
    }

    yield switchCase;
  }
}
