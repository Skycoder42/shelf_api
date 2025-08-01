import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_query_parameter.dart';
import '../../models/opaque_constant.dart';
import '../../util/code/if.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';

@internal
final class QueryBuilder {
  final List<EndpointQueryParameter> _queryParameters;
  final Reference _requestRef;

  const QueryBuilder(this._queryParameters, this._requestRef);

  Code get variables => _queryParameters.isNotEmpty
      ? _QueryVariablesBuilder(_queryParameters, _requestRef)
      : const Code('');

  Map<String, Expression> get parameters => _queryParameters.isNotEmpty
      ? Map.fromEntries(_QueryParamsBuilder(_queryParameters).build())
      : const {};
}

final class _QueryVariablesBuilder extends CodeBuilder {
  static const _queryRef = Reference(r'$query');

  final List<EndpointQueryParameter> _queryParameters;
  final Reference _requestRef;

  const _QueryVariablesBuilder(this._queryParameters, this._requestRef);

  @override
  Iterable<Code> build() sync* {
    yield declareFinal(_queryRef.symbol!)
        .assign(_requestRef.property('url').property('queryParametersAll'))
        .statement;

    for (final param in _queryParameters) {
      final paramRef = refer(param.handlerParamName);
      var getValueExpr = _queryRef.index(
        literalString(param.queryName, raw: true),
      );
      if (!param.isList) {
        getValueExpr = getValueExpr.nullSafeProperty('firstOrNull');
      }
      yield declareFinal(paramRef.symbol!).assign(getValueExpr).statement;

      if (!param.isOptional) {
        yield If(
          paramRef.equalTo(literalNull),
          Types.shelfResponse
              .newInstanceNamed('badRequest', const [], {
                'body': literalString(
                  'Missing required query parameter ${param.queryName}',
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
      final paramRef = refer(param.handlerParamName);
      final convertExpression = _convertExpression(param, paramRef);

      if (param.isOptional) {
        if (param.defaultValue case final String code) {
          yield MapEntry(
            param.paramName,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, CodeExpression(Code(code))),
          );
        } else {
          yield MapEntry(
            param.paramName,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, literalNull),
          );
        }
      } else {
        yield MapEntry(param.paramName, convertExpression);
      }
    }
  }

  Expression _convertExpression(
    EndpointQueryParameter param,
    Reference paramRef,
  ) {
    if (param.customParse case final OpaqueConstant parse) {
      return Constants.fromConstant(parse).call([paramRef]);
    }

    if (param.isString) {
      return paramRef;
    }

    if (param.isList) {
      return paramRef
          .property('map')
          .call([_convertNonStringExpression(param)])
          .property('toList')
          .call(const []);
    }

    return _convertNonStringExpression(param).call([paramRef]);
  }

  Expression _convertNonStringExpression(EndpointQueryParameter param) {
    if (param.isEnum) {
      return Types.fromType(
        param.type,
        isNull: false,
      ).property('values').property('byName');
    }

    return Types.fromType(param.type, isNull: false).property('parse');
  }
}
