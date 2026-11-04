import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports to extend private class
import 'package:code_builder/src/specs/code.dart' show CodeVisitor;
import 'package:meta/meta.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
abstract base class const CodeBuilder() implements Code {
  Iterable<Code> build();

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(build()).accept(visitor, context);
}
