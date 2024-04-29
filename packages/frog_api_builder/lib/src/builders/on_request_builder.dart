import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../readers/endpoint_methods_reader.dart';
import '../util/code/switch.dart';
import '../util/constants.dart';
import '../util/types.dart';
import 'spec_builder.dart';

class _AsyncRef {
  bool isAsync = false;
}

@internal
final class OnRequestBuilder extends SpecBuilder<Method> {
  static const _contextRef = Reference('context');
  static const _endpointRef = Reference(r'$endpoint');

  final EndpointMethodsReader _endpointMethodsReader =
      const EndpointMethodsReader();

  final ClassElement _class;

  OnRequestBuilder(this._class);

  @override
  Method build() => Method(
        (b) {
          final asyncRef = _AsyncRef();
          b
            ..name = 'onRequest'
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = _contextRef.symbol!
                  ..type = Types.requestContext,
              ),
            )
            ..body = Block.of(_buildBody(asyncRef))
            ..modifier = asyncRef.isAsync ? MethodModifier.async : null
            ..returns = asyncRef.isAsync
                ? Types.future(Types.response)
                : Types.response;
        },
      );

  Iterable<Code> _buildBody(_AsyncRef asyncRef) sync* {
    final methods = _endpointMethodsReader.readMethods(_class);
    if (methods.isEmpty) {
      yield Types.response
          .newInstance(const [], {
            'statusCode': Types.httpStatus.property('notImplemented'),
          })
          .returned
          .statement;
      return;
    }

    yield declareFinal(_endpointRef.symbol!)
        .assign(Types.fromClass(_class).newInstance([_contextRef]))
        .statement;

    final switchCase = Switch(
      _contextRef.property('request').property('method'),
    )..defaultCase = Types.response
        .newInstance(const [], {
          'statusCode': Types.httpStatus.property('methodNotAllowed'),
        })
        .returned
        .statement;

    for (final MapEntry(key: httpMethod, value: endpointMethod)
        in methods.entries) {
      switchCase.addCase(
        Types.httpMethod.property(httpMethod.name),
        Block.of(_buildInvocation(endpointMethod, asyncRef)),
        // _endpointRef
        //     .property(endpointMethod.element.name)
        //     .call(const [])
        //     .returned
        //     .statement,
      );
    }

    yield switchCase;
  }

  Iterable<Code> _buildInvocation(
    EndpointMethod method,
    _AsyncRef asyncRef,
  ) sync* {
    var invocation = _endpointRef.property(method.element.name).call(const []);
    if (method.isAsync) {
      asyncRef.isAsync = true;
      invocation = invocation.awaited;
    }

    switch (method.returnType) {
      case EndpointReturnType.noContent:
        yield invocation.statement;
      case EndpointReturnType.string:
        yield Types.response
            .newInstance([], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.bytes:
        yield Types.response
            .newInstanceNamed('bytes', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.stringStream:
        yield Types.response
            .newInstanceNamed('stream', [], {
              'body': invocation
                  .property('transform')
                  .call([Constants.utf8.property('encoder')]),
            })
            .returned
            .statement;
      case EndpointReturnType.byteStream:
        yield Types.response
            .newInstanceNamed('stream', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.json:
        yield Types.response
            .newInstanceNamed('json', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.response:
        yield invocation.returned.statement;
    }
  }
}
