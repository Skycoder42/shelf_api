import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_path_parameter.dart';
import '../../models/opaque_constant.dart';
import '../../util/code/literal_string_builder.dart';
import '../../util/constants.dart';
import '../../util/types.dart';
import '../base/expression_builder.dart';

@internal
final class PathBuilder extends ExpressionBuilder {
  final ApiClass _apiClass;
  final Endpoint _endpoint;
  final EndpointMethod _method;

  const PathBuilder(this._apiClass, this._endpoint, this._method);

  @override
  Expression build() {
    final pathBuilder = LiteralStringBuilder();
    var hasTrailingSlash = false;

    if (_apiClass.basePath case final String path) {
      pathBuilder.addLiteral(path);
      hasTrailingSlash = path.endsWith('/');
    }

    if (_endpoint.path case final String path) {
      pathBuilder.addLiteral(hasTrailingSlash ? path.substring(1) : path);
      hasTrailingSlash = path.endsWith('/');
    }

    final methodPath = hasTrailingSlash
        ? _method.path.substring(1)
        : _method.path;
    if (_method.pathParameters.isEmpty) {
      pathBuilder.addLiteral(methodPath);
    } else {
      pathBuilder.addTemplate(methodPath, {
        for (final pathParam in _method.pathParameters)
          _paramPattern(pathParam): _paramValue(pathParam),
      });
    }

    return pathBuilder;
  }

  RegExp _paramPattern(EndpointPathParameter pathParam) =>
      RegExp('<${RegExp.escape(pathParam.name)}(?:\\|.+?)?>');

  Expression _paramValue(EndpointPathParameter pathParam) {
    final paramRef = refer(pathParam.name);

    Expression paramStringRef;
    if (pathParam.customToString case final OpaqueConstant customToString) {
      paramStringRef = Constants.fromConstant(customToString).call([paramRef]);
    } else if (pathParam.isEnum) {
      paramStringRef = paramRef.property('name');
    } else if (pathParam.isDateTime) {
      paramStringRef = paramRef.property('toIso8601String').call(const []);
    } else if (pathParam.urlEncode && !pathParam.isString) {
      paramStringRef = paramRef.property('toString').call(const []);
    } else {
      paramStringRef = paramRef;
    }

    if (pathParam.urlEncode) {
      return Types.uri.property('encodeComponent').call([paramStringRef]);
    } else {
      return paramStringRef;
    }
  }
}
