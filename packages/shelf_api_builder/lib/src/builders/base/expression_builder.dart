import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
abstract base class const ExpressionBuilder() extends Expression {
  Expression build();

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
