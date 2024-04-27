import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

@internal
abstract base class SpecBuilder<T extends Spec> implements Spec {
  const SpecBuilder();

  @protected
  T build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
