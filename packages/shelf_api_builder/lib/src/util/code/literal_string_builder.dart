import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
class LiteralStringBuilder extends Expression {
  final _parts = <_StringInfo>[];

  void addLiteral(String string) => _parts.add(_LiteralStringInfo(string));

  void addTemplate(String template, Map<Pattern, Expression> values) =>
      _parts.add(_TemplateStringInfo(template, values));

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) {
    var currentContext = context;
    for (final code in _build()) {
      currentContext = visitor.visitCodeExpression(
        CodeExpression(code),
        context,
      );
    }
    return currentContext!;
  }

  Iterable<Code> _build() sync* {
    yield const Code("'");
    for (final part in _parts) {
      yield* part.stringCode;
    }
    yield const Code("'");
  }
}

sealed class _StringInfo {
  final _dollarQuoteRegexp = RegExp(r"""(?=[$'\\])""");

  Iterable<Code> get stringCode;

  String _escaped(String string) => string.replaceAll(_dollarQuoteRegexp, r'\');
}

class _LiteralStringInfo extends _StringInfo {
  final String string;

  _LiteralStringInfo(this.string);

  @override
  Iterable<Code> get stringCode sync* {
    yield Code(_escaped(string));
  }
}

class _TemplateStringInfo extends _StringInfo {
  final String template;
  final Map<Pattern, Expression> values;

  _TemplateStringInfo(this.template, this.values);

  @override
  Iterable<Code> get stringCode sync* {
    final replacements = <(int, int, Expression)>[];
    for (final MapEntry(key: pattern, value: value) in values.entries) {
      final matches = pattern.allMatches(template);
      for (final match in matches) {
        replacements.add((match.start, match.end, value));
      }
    }

    replacements.sort((a, b) {
      final startCmp = a.$1.compareTo(b.$1);
      return startCmp != 0 ? startCmp : a.$2.compareTo(b.$2);
    });

    var previousEnd = 0;
    for (final (start, end, value) in replacements) {
      if (start < previousEnd) {
        throw StateError('Cannot have replacement patterns that overlap!');
      }

      if (previousEnd != start) {
        yield Code(_escaped(template.substring(previousEnd, start)));
      }
      yield const Code(r'${');
      yield value.code;
      yield const Code('}');
      previousEnd = end;
    }

    if (previousEnd < template.length) {
      yield Code(_escaped(template.substring(previousEnd)));
    }
  }
}
