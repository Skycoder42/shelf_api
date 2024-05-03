import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_method.dart';
import '../base/code_builder.dart';
import 'body_builder.dart';
import 'query_builder.dart';
import 'response_builder.dart';

@internal
final class MethodBuilder extends CodeBuilder {
  final EndpointMethod _method;
  final Reference _contextRef;
  final Reference _endpointRef;

  const MethodBuilder(
    this._method,
    this._contextRef,
    this._endpointRef,
  );

  @override
  Iterable<Code> build() sync* {
    final bodyBuilder = BodyBuilder(_method.body, _contextRef);
    final queryBuilder = QueryBuilder(_method.queryParameters, _contextRef);

    yield bodyBuilder.variables;
    yield queryBuilder.variables;

    var invocation = _endpointRef.property(_method.name).call(
          bodyBuilder.parameters,
          queryBuilder.parameters,
        );
    if (_method.response.isAsync) {
      invocation = invocation.awaited;
    }

    yield ResponseBuilder(_method.response, invocation);
  }
}
