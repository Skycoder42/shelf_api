import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class const SpecBuilder<T extends Spec>() implements Spec {
  @protected
  T build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
