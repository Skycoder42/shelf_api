import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_path_parameter.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../../util/types.dart';

@internal
final class PathBuilder {
  final List<EndpointPathParameter> _pathParameters;

  const PathBuilder(this._pathParameters);

  Iterable<Expression> build() sync* {
    for (final param in _pathParameters) {
      final paramRef = refer(param.handlerParamName);

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
