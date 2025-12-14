import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'stringifiable_reader.dart';

@internal
class QueryParamReader with StringifiableReader {
  @override
  final ConstantReader constantReader;

  QueryParamReader(this.constantReader) {
    if (!constantReader.instanceOf(TypeCheckers.queryParam)) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply QueryParamReader on QueryParam annotations.',
      );
    }
  }

  String? get name {
    final nameReader = constantReader.read('name');
    return nameReader.isNull ? null : nameReader.stringValue;
  }
}

@internal
extension QueryParamElementX on FormalParameterElement {
  QueryParamReader? get queryParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.queryParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : QueryParamReader(annotation);
  }
}
