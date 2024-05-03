import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/endpoint_path_parameter.dart';
import '../models/opaque_constant.dart';
import '../util/code/if.dart';
import '../util/constants.dart';
import '../util/types.dart';
import 'base/code_builder.dart';

@internal
final class PathBuilder {
  final List<EndpointPathParameter> _pathParameters;
  final Reference _requestRef;

  const PathBuilder(this._pathParameters, this._requestRef);

  Code get variables => _pathParameters.isNotEmpty
      ? _PathVariablesBuilder(_pathParameters, _requestRef)
      : const Code('');

  List<Expression> get parameters => _pathParameters.isNotEmpty
      ? _PathParamsBuilder(_pathParameters).build().toList()
      : const [];

  static Reference _paramRef(EndpointPathParameter param) =>
      refer('\$\$${param.name}');
}

final class _PathVariablesBuilder extends CodeBuilder {
  static const _paramsRef = Reference(r'$params');

  final List<EndpointPathParameter> _pathParameters;
  final Reference _requestRef;

  const _PathVariablesBuilder(this._pathParameters, this._requestRef);

  @override
  Iterable<Code> build() sync* {
    yield declareFinal(_paramsRef.symbol!)
        .assign(
          _requestRef.property('params'),
        )
        .statement;

    for (final param in _pathParameters) {
      final paramRef = PathBuilder._paramRef(param);
      yield declareFinal(paramRef.symbol!)
          .assign(_paramsRef.index(literalString(param.name, raw: true)))
          .statement;

      yield If(
        paramRef.equalTo(literalNull),
        Types.response
            .newInstanceNamed('badRequest', const [], {
              'body': literalString(
                'Missing required path parameter ${param.name}',
                raw: true,
              ),
            })
            .returned
            .statement,
      );
    }
  }
}

final class _PathParamsBuilder {
  final List<EndpointPathParameter> _pathParameters;

  _PathParamsBuilder(this._pathParameters);

  Iterable<Expression> build() sync* {
    for (final param in _pathParameters) {
      final paramRef = refer('\$\$${param.name}');

      if (param.customParse case final OpaqueConstant parse) {
        yield Constants.fromConstant(parse).call([paramRef]);
      } else if (param.isString) {
        yield paramRef;
      } else {
        yield Types.fromType(param.type, isNull: false)
            .newInstanceNamed('parse', [paramRef]);
      }
    }
  }
}
