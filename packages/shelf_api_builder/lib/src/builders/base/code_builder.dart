import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports to extend private class
import 'package:code_builder/src/specs/code.dart' show CodeVisitor;
import 'package:meta/meta.dart';

@internal
abstract base class CodeBuilder implements Code {
  const CodeBuilder();

  Iterable<Code> build();

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(build()).accept(visitor, context);
}
