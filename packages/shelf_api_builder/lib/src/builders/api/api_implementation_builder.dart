import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'api_handler_builder.dart';

@internal
final class ApiImplementationBuilder extends SpecBuilder<Class> {
  static const _routerRef = Reference(r'$router');
  static const _requestRef = Reference('request');

  final ApiClass _apiClass;

  ApiImplementationBuilder(this._apiClass);

  @override
  Class build() => Class(
        (b) => b
          ..name = _apiClass.implementationName
          ..fields.add(
            Field(
              (b) => b
                ..name = _routerRef.symbol
                ..modifier = FieldModifier.final$
                ..type = Types.router,
            ),
          )
          ..constructors.add(
            Constructor(
              (b) => b
                ..initializers.add(
                  _routerRef.assign(Types.router.newInstance(const [])).code,
                )
                ..body = Block.of(_buildConstructorBody()),
            ),
          )
          ..methods.add(
            Method(
              (b) => b
                ..name = 'call'
                ..returns = Types.future(Types.shelfResponse)
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = 'request'
                      ..type = Types.shelfRequest,
                  ),
                )
                ..body = _routerRef.call([_requestRef]).code,
            ),
          )
          ..methods.addAll([
            for (final endpoint in _apiClass.endpoints)
              for (final method in endpoint.methods)
                ApiHandlerBuilder(endpoint, method).build(),
          ]),
      );

  Iterable<Code> _buildConstructorBody() sync* {
    Expression router = _routerRef;

    if (_apiClass.basePath != null) {
      router = Types.router.newInstance(const []);
    }

    for (final endpoint in _apiClass.endpoints) {
      Expression endpointRouter;
      if (endpoint.path != null) {
        endpointRouter = Types.router.newInstance(const []);
      } else {
        endpointRouter = router;
      }

      for (final method in endpoint.methods) {
        endpointRouter = endpointRouter.cascade('add').call([
          literalString(method.httpMethod),
          literalString(method.path, raw: true),
          refer(ApiHandlerBuilder.handlerMethodName(endpoint, method)),
        ]);
      }

      if (endpoint.path case final String path) {
        router = router.cascade('mount').call([
          literalString(path, raw: true),
          endpointRouter,
        ]);
      } else {
        router = endpointRouter;
      }
    }

    if (_apiClass.basePath case final String path) {
      router = _routerRef.cascade('mount').call([
        literalString(path, raw: true),
        router,
      ]);
    }

    yield router.statement;
  }
}
