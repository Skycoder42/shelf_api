import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/code_gen.dart';
import 'package:meta/meta.dart';

import '../models/opaque_constant.dart';

@internal
abstract base class Constants {
  Constants._();

  static const utf8 = Reference('utf8', 'dart:convert');

  static const json = Reference('json', 'dart:convert');

  static Expression fromConstant(OpaqueConstant constant) {
    if (constant is! RevivedOpaqueConstant) {
      throw ArgumentError.value(
        constant,
        'constant',
        'Unsupported OpaqueConstant type: ${constant.runtimeType}',
      );
    }

    final expr = constant.revivable.toExpression();
    if (expr is Reference && constant.source != null) {
      return Reference(expr.symbol, constant.source.toString());
    }
    return expr;
  }
}
