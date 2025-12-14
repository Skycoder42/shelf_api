import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports for private api
import 'package:code_builder/src/specs/code.dart' show CodeVisitor;
import 'package:meta/meta.dart';

@internal
class Try implements Code {
  final Code _body;
  final _catches = <(TypeReference?, Reference?, Reference?, Code)>{};
  Code? finallyBody;

  Try(this._body);

  void addCatch(
    Code body, {
    TypeReference? on,
    Reference? error,
    Reference? stackTrace,
  }) {
    _catches.add((on, error, stackTrace, body));
  }

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) =>
      Block.of(_build()).accept(visitor, context);

  Iterable<Code> _build() sync* {
    yield const Code('try{');
    yield _body;
    yield const Code('}');
    for (final (on, error, stackTrace, body) in _catches) {
      if (on != null) {
        yield const Code('on ');
        yield on.code;
        yield const Code(' ');
      }

      if (error != null || stackTrace != null || on == null) {
        yield const Code('catch(');
        yield error?.code ?? const Reference('e').code;
        if (stackTrace != null) {
          yield const Code(',');
          yield stackTrace.code;
        }
        yield const Code(')');
      }

      yield const Code('{');
      yield body;
      yield const Code('}');
    }

    if (finallyBody != null) {
      yield const Code('finally{');
      yield finallyBody!;
      yield const Code('}');
    }
  }
}
