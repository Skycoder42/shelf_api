import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../util/code/try.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'body_builder.dart';
import 'path_builder.dart';
import 'query_builder.dart';
import 'response_builder.dart';

@internal
final class ApiHandlerBuilder extends SpecBuilder<Method> {
  static const _endpointRef = Reference(r'$endpoint');
  static const _requestRef = Reference(r'$request');

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

  @override
  Method build() => Method(
        (b) => b
          ..name = handlerMethodName(_endpoint, _method)
          ..returns = Types.future(Types.shelfResponse)
          ..modifier = MethodModifier.async
          ..requiredParameters.addAll(_buildParameters())
          ..body = Block.of(_buildBody()),
      );

  Iterable<Parameter> _buildParameters() sync* {
    yield Parameter(
      (b) => b
        ..name = _requestRef.symbol!
        ..type = Types.shelfRequest,
    );

    for (final pathParam in _method.pathParameters) {
      yield Parameter(
        (b) => b
          ..name = pathParam.handlerParamName
          ..type = Types.string,
      );
    }
  }

  Iterable<Code> _buildBody() sync* {
    yield declareFinal(_endpointRef.symbol!)
        .assign(
          Types.fromType(_endpoint.endpointType).newInstance([_requestRef]),
        )
        .statement;

    yield _endpointRef.property('init').call(const []).awaited.statement;
    if (_method.isStream) {
      yield* _buildTryBody();
    } else {
      yield Try(Block.of(_buildTryBody()))
        ..finallyBody =
            _endpointRef.property('dispose').call(const []).awaited.statement;
    }
  }

  Iterable<Code> _buildTryBody() sync* {
    final bodyBuilder = BodyBuilder(_method.body, _requestRef);
    final pathBuilder = PathBuilder(_method.pathParameters);
    final queryBuilder = QueryBuilder(_method.queryParameters, _requestRef);

    yield bodyBuilder.variables;
    yield queryBuilder.variables;

    var invocation = _endpointRef.property(_method.name).call(
      [
        ...pathBuilder.build(),
        if (bodyBuilder.parameter case final Expression param) param,
      ],
      queryBuilder.parameters,
    );
    if (_method.isAsync) {
      invocation = invocation.awaited;
    } else if (_method.isStream) {
      invocation = invocation.property('onFinished').call([
        _endpointRef.property('dispose'),
      ]);
    }
    yield ResponseBuilder(_method.response, invocation);
  }
}
