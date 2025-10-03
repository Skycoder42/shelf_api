import 'package:analyzer/dart/element/element2.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'stringifiable_reader.dart';

@internal
class PathParamReader with StringifiableReader {
  @override
  final ConstantReader constantReader;

  PathParamReader(this.constantReader) {
    if (!constantReader.instanceOf(TypeCheckers.pathParam)) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply PathParamReader on PathParam annotations.',
      );
    }
  }

  bool get urlEncode => constantReader.read('urlEncode').boolValue;
}

@internal
extension PathParamElementX on FormalParameterElement {
  PathParamReader? get pathParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.pathParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : PathParamReader(annotation);
  }
}
