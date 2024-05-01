// ignore: implementation_imports
import 'package:code_builder/src/specs/code.dart';
import 'package:meta/meta.dart';

@internal
abstract base class CodeBuilder implements Code {
  const CodeBuilder();

  Iterable<Code> build();

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(build()).accept(visitor, context);
}
