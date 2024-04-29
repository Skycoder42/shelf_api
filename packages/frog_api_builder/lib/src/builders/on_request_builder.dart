import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../util/types.dart';
import 'spec_builder.dart';

class _AsyncRef {
  bool isAsync = false;
}

@internal
final class OnRequestBuilder extends SpecBuilder<Method> {
  static const _contextRef = Reference('context');

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
    yield literalString('Unimplemented').thrown.statement;
  }
}
