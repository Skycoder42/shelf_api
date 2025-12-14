import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
extension ExpressionX on Expression {
  Expression get yielded =>
      CodeExpression(Block.of([const Code('yield '), code]));

  Expression get yieldedStar =>
      CodeExpression(Block.of([const Code('yield* '), code]));

  // ignore: avoid_positional_boolean_parameters for obvious use case
  Expression autoProperty(String name, bool isNullable) =>
      isNullable ? nullSafeProperty(name) : property(name);
}
