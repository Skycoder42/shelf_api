import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
extension ExpressionX on Expression {
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);
}
