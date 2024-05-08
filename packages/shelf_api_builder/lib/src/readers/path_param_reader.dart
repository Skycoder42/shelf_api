import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'stringifiable_reader.dart';

@internal
class PathParamReader with StringifiableReader {
  @override
  final ConstantReader constantReader;

  PathParamReader(this.constantReader) {
    if (!constantReader.instanceOf(const TypeChecker.fromRuntime(PathParam))) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply PathParamReader on PathParam annotations.',
      );
    }
  }
}

@internal
extension PathParamElementX on ParameterElement {
  PathParamReader? get pathParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.pathParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : PathParamReader(annotation);
  }
}
