import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../util/code/try.dart';
import '../../util/types.dart';
import 'body_builder.dart';
import 'path_builder.dart';
import 'query_builder.dart';
import 'response_builder.dart';

@internal
final class ApiHandlerBuilder {
  static const _endpointRef = Reference(r'$endpoint');
  static const _requestRef = Reference('request');

  final Endpoint _endpoint;
  final EndpointMethod _method;

  static String handlerMethodName(
    Endpoint endpoint,
    EndpointMethod method,
  ) =>
      '_handler\$${endpoint.name}\$${method.name}';

  const ApiHandlerBuilder(
    this._endpoint,
    this._method,
  );

  Method build() => Method(
        (b) => b
          ..name = handlerMethodName(_endpoint, _method)
          ..returns = Types.future(Types.response)
          ..modifier = MethodModifier.async
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = _requestRef.symbol!
                ..type = Types.request,
            ),
          )
          ..body = Block.of(_buildBody()),
      );

  Iterable<Code> _buildBody() sync* {
    yield declareFinal(_endpointRef.symbol!)
        .assign(
          Types.fromType(_endpoint.endpointType).newInstance([_requestRef]),
        )
        .statement;

    yield _endpointRef.property('init').call(const []).awaited.statement;
    yield Try(Block.of(_buildTryBody()))
      ..finallyBody =
          _endpointRef.property('dispose').call(const []).awaited.statement;
  }

  Iterable<Code> _buildTryBody() sync* {
    final bodyBuilder = BodyBuilder(_method.body, _requestRef);
    final pathBuilder = PathBuilder(_method.pathParameters, _requestRef);
    final queryBuilder = QueryBuilder(_method.queryParameters, _requestRef);

    yield bodyBuilder.variables;
    yield pathBuilder.variables;
    yield queryBuilder.variables;

    var invocation = _endpointRef.property(_method.name).call(
      [
        if (bodyBuilder.parameter case final Expression param) param,
        ...pathBuilder.parameters,
      ],
      queryBuilder.parameters,
    );
    if (_method.response.isAsync) {
      invocation = invocation.awaited;
    }
    yield ResponseBuilder(_method.response, invocation);
  }
}
