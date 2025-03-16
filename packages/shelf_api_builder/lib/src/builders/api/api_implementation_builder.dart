import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'api_handler_builder.dart';

@internal
final class ApiImplementationBuilder extends SpecBuilder<Class> {
  static const _handlerRef = Reference(r'_$handler');
  static const _requestRef = Reference('request');

  final ApiClass _apiClass;

  ApiImplementationBuilder(this._apiClass);

  @override
  Class build() => Class(
    (b) =>
        b
          ..name = _apiClass.implementationName
          ..fields.add(
            Field(
              (b) =>
                  b
                    ..name = _handlerRef.symbol
                    ..late = true
                    ..modifier = FieldModifier.final$
                    ..type = Types.handler,
            ),
          )
          ..constructors.add(
            Constructor((b) => b..body = Block.of(_buildConstructorBody())),
          )
          ..methods.add(
            Method(
              (b) =>
                  b
                    ..name = 'call'
                    ..returns = Types.futureOr(Types.shelfResponse)
                    ..requiredParameters.add(
                      Parameter(
                        (b) =>
                            b
                              ..name = 'request'
                              ..type = Types.shelfRequest,
                      ),
                    )
                    ..body =
                        ApiImplementationBuilder._handlerRef.call([
                          ApiImplementationBuilder._requestRef,
                        ]).code,
            ),
          )
          ..methods.addAll([
            for (final endpoint in _apiClass.endpoints)
              for (final method in endpoint.methods)
                ApiHandlerBuilder(endpoint, method).build(),
          ]),
  );

  Iterable<Code> _buildConstructorBody() sync* {
    var handler = Types.router.newInstance(const []);

    handler = _routeEndpoints(handler);

    if (_apiClass.middleware case final OpaqueConstant middleware) {
      handler = _withMiddleware(handler, middleware);
    }

    if (_apiClass.basePath case final String path) {
      handler = Types.router.newInstance(const []).cascade('mount').call([
        literalString(path, raw: true),
        handler,
      ]);
    }

    yield _handlerRef.assign(handler).statement;
  }

  Expression _routeEndpoints(Expression router) {
    var currentRouterRef = router;
    for (final endpoint in _apiClass.endpoints) {
      currentRouterRef = _routeEndpoint(currentRouterRef, endpoint);
    }
    return currentRouterRef;
  }

  Expression _routeEndpoint(Expression router, Endpoint endpoint) {
    final middleware = endpoint.middleware;
    final endpointNeedsRouter = endpoint.path != null || middleware != null;

    var endpointRouter =
        endpointNeedsRouter ? Types.router.newInstance(const []) : router;

    endpointRouter = _routeMethods(endpointRouter, endpoint);

    if (middleware != null) {
      endpointRouter = _withMiddleware(endpointRouter, middleware);
    }

    if (endpointNeedsRouter) {
      return router.cascade('mount').call([
        literalString(endpoint.path ?? '/', raw: true),
        endpointRouter,
      ]);
    } else {
      return endpointRouter;
    }
  }

  Expression _routeMethods(Expression router, Endpoint endpoint) {
    var currentRouterRef = router;
    for (final method in endpoint.methods) {
      currentRouterRef = currentRouterRef.cascade('add').call([
        literalString(method.httpMethod),
        literalString(method.path, raw: true),
        refer(ApiHandlerBuilder.handlerMethodName(endpoint, method)),
      ]);
    }
    return currentRouterRef;
  }

  Expression _withMiddleware(Expression handler, OpaqueConstant middleware) =>
      Types.pipeline
          .constInstance(const [])
          .property('addMiddleware')
          .call([Constants.fromConstant(middleware).call(const [])])
          .property('addHandler')
          .call([handler]);
}
