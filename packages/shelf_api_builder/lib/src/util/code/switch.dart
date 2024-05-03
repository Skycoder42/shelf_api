import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/specs/code.dart';
import 'package:meta/meta.dart';

@internal
class Switch implements Code {
  final Expression _condition;
  final _cases = <(Expression, Code?)>[];
  Code? defaultCase;

  Switch(this._condition);

  void addCase(Expression expression, [Code? body]) =>
      _cases.add((expression, body));

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(_build()).accept(visitor, context);

  Iterable<Code> _build() sync* {
    yield const Code('switch(');
    yield _condition.code;
    yield const Code('){');
    for (final (condition, body) in _cases) {
      yield const Code('case ');
      yield condition.code;
      yield const Code(':');
      if (body != null) {
        yield body;
      }
    }
    if (defaultCase case final Code body) {
      yield const Code('default:');
      yield body;
    }
    yield const Code('}');
  }
}
