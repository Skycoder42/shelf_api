import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class ExpressionBuilder extends Expression {
  const ExpressionBuilder();

  Expression build();

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
