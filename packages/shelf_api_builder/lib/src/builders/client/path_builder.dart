import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_path_parameter.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../base/expression_builder.dart';

@internal
final class PathBuilder extends ExpressionBuilder {
  final ApiClass _apiClass;
  final Endpoint _endpoint;
  final EndpointMethod _method;

  const PathBuilder(this._apiClass, this._endpoint, this._method);

  @override
  Expression build() => LiteralString((pathBuilder) {
    var hasTrailingSlash = false;

    if (_apiClass.basePath case final String path) {
      pathBuilder.addString(path);
      hasTrailingSlash = path.endsWith('/');
    }

    if (_endpoint.path case final String path) {
      pathBuilder.addString(hasTrailingSlash ? path.substring(1) : path);
      hasTrailingSlash = path.endsWith('/');
    }

    final methodPath = hasTrailingSlash
        ? _method.path.substring(1)
        : _method.path;
    if (_method.pathParameters.isEmpty) {
      pathBuilder.addString(methodPath);
    } else {
      _convertPathTemplate(pathBuilder, methodPath, {
        for (final pathParam in _method.pathParameters)
          _paramPattern(pathParam): _paramValue(pathParam),
      });
    }
  });

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
      return CoreTypes.$Uri.property('encodeComponent').call([paramStringRef]);
    } else {
      return paramStringRef;
    }
  }

  void _convertPathTemplate(
    LiteralStringBuilder builder,
    String template,
    Map<Pattern, Expression> values,
  ) {
    final replacements = <(int, int, Expression)>[];
    for (final MapEntry(key: pattern, :value) in values.entries) {
      final matches = pattern.allMatches(template);
      for (final match in matches) {
        replacements.add((match.start, match.end, value));
      }
    }

    replacements.sort((a, b) {
      final startCmp = a.$1.compareTo(b.$1);
      return startCmp != 0 ? startCmp : a.$2.compareTo(b.$2);
    });

    var previousEnd = 0;
    for (final (start, end, value) in replacements) {
      if (start < previousEnd) {
        throw StateError('Cannot have replacement patterns that overlap!');
      }

      if (previousEnd != start) {
        builder.addString(template.substring(previousEnd, start));
      }
      builder.addParameter(value);
      previousEnd = end;
    }

    if (previousEnd < template.length) {
      builder.addString(template.substring(previousEnd));
    }
  }
}
