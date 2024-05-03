import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';

@internal
class QueryParamReader {
  final ConstantReader constantReader;

  QueryParamReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(QueryParam)),
          'Can only apply QueryParamReader on QueryParam annotations.',
        );

  String? get name {
    final nameReader = constantReader.read('name');
    return nameReader.isNull ? null : nameReader.stringValue;
  }

  String? get parse {
    final parseReader = constantReader.read('parse');
    return parseReader.isNull ? null : (parseReader.revive().accessor);
  }
}

@internal
extension QueryParamElementX on ParameterElement {
  QueryParamReader? get queryParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.queryParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : QueryParamReader(annotation);
  }
}
