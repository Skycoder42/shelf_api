import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_query_parameter.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/expression_builder.dart';

@internal
final class QueryBuilder extends ExpressionBuilder {
  static const _valueRef = Reference(r'$value');

  final List<EndpointQueryParameter> _queryParams;

  const QueryBuilder(this._queryParams);

  bool get hasParams => _queryParams.isNotEmpty;

  @override
  Expression build() => literalMap(
        Map.fromEntries(_buildEntries()),
        Types.string,
        Types.dynamic$,
      );

  Iterable<MapEntry<Expression, Expression>> _buildEntries() sync* {
    for (final queryParam in _queryParams) {
      final paramRef = refer(queryParam.paramName);
      final key = _ifNotNullKey(
        queryParam,
        literalString(queryParam.queryName, raw: true),
        paramRef,
      );

      Expression value;
      if (queryParam.customToString case final OpaqueConstant customToString) {
        value = Constants.fromConstant(customToString).call([paramRef]);
      } else if (queryParam.isString) {
        value = paramRef;
      } else if (queryParam.isList) {
        value = paramRef
            .property('map')
            .call([
              Method(
                (b) => b
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b..name = _valueRef.symbol!,
                    ),
                  )
                  ..body = _valueRef.property('toString').call(const []).code,
              ).closure,
            ])
            .property('toList')
            .call(const []);
      } else {
        value = paramRef.property('toString').call(const []);
      }

      yield MapEntry(key, value);
    }
  }

  Expression _ifNotNullKey(
    EndpointQueryParameter param,
    Expression key,
    Expression value,
  ) {
    if (!param.isOptional) {
      return key;
    }

    return CodeExpression(
      Block.of([
        const Code('if('),
        value.notEqualTo(literalNull).code,
        const Code(')'),
        key.code,
      ]),
    );
  }
}
