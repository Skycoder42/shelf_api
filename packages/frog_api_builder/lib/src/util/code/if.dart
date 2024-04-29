import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/specs/code.dart';
import 'package:meta/meta.dart';

@internal
class If implements Code {
  final List<(Expression, Code)> _branches;
  Code? orElse;

  If(Expression condition, Code body) : _branches = [(condition, body)];

  void elif(Expression condition, Code body) {
    _branches.add((condition, body));
  }

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(_build()).accept(visitor, context);

  Iterable<Code> _build() sync* {
    yield const Code('if(');
    yield _branches.first.$1.code;
    yield const Code('){');
    yield _branches.first.$2;
    yield const Code('}');

    for (final elif in _branches.skip(1)) {
      yield const Code('else if(');
      yield elif.$1.code;
      yield const Code('){');
      yield elif.$2;
      yield const Code('}');
    }

    if (orElse case final Code body) {
      yield const Code('else{');
      yield body;
      yield const Code('}');
    }
  }
}
