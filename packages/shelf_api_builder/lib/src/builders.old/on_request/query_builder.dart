import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_query_parameter.dart';
import '../../util/code/if.dart';
import '../../util/types.dart';
import '../../builders/base/code_builder.dart';

@internal
final class QueryBuilder {
  final List<EndpointQueryParameter> _queryParameters;
  final Reference _contextRef;

  const QueryBuilder(this._queryParameters, this._contextRef);

  Code get variables => _queryParameters.isNotEmpty
      ? _QueryVariablesBuilder(_queryParameters, _contextRef)
      : const Code('');

  Map<String, Expression> get parameters => _queryParameters.isNotEmpty
      ? Map.fromEntries(_QueryParamsBuilder(_queryParameters).build())
      : const {};

  static Reference _paramRef(EndpointQueryParameter param) =>
      refer('\$\$${param.name}');
}

final class _QueryVariablesBuilder extends CodeBuilder {
  static const _queryRef = Reference(r'$query');

  final List<EndpointQueryParameter> _queryParameters;
  final Reference _contextRef;

  const _QueryVariablesBuilder(this._queryParameters, this._contextRef);

  @override
  Iterable<Code> build() sync* {
    yield declareFinal(_queryRef.symbol!)
        .assign(
          _contextRef
              .property('request')
              .property('url')
              .property('queryParameters'),
        )
        .statement;

    for (final param in _queryParameters) {
      final paramRef = QueryBuilder._paramRef(param);
      yield declareFinal(paramRef.symbol!)
          .assign(_queryRef.index(literalString(param.name, raw: true)))
          .statement;

      if (!param.isOptional) {
        yield If(
          paramRef.equalTo(literalNull),
          Types.response
              .newInstance(const [], {
                'statusCode': Types.httpStatus.property('badRequest'),
                'body': literalString(
                  'Missing required query parameter ${param.name}',
                  raw: true,
                ),
              })
              .returned
              .statement,
        );
      }
    }
  }
}

final class _QueryParamsBuilder {
  final List<EndpointQueryParameter> _queryParameters;

  _QueryParamsBuilder(this._queryParameters);

  Iterable<MapEntry<String, Expression>> build() sync* {
    for (final param in _queryParameters) {
      final paramRef = refer('\$\$${param.name}');
      final convertExpression = param.isString
          ? paramRef
          : Types.fromType(param.type, isNull: false)
              .newInstanceNamed('parse', [paramRef]);

      if (param.isOptional) {
        if (param.defaultValue case final String code) {
          yield MapEntry(
            param.name,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, CodeExpression(Code(code))),
          );
        } else {
          yield MapEntry(
            param.name,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, literalNull),
          );
        }
      } else {
        yield MapEntry(param.name, convertExpression);
      }
    }
  }
}
