import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'serializable_reader.dart';

@internal
class BodyParamReader with SerializableReader {
  @override
  final ConstantReader constantReader;

  BodyParamReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(BodyParam)),
          'Can only apply BodyParamReader on BodyParam annotations.',
        );
}

@internal
extension BodyParamElementX on ParameterElement {
  BodyParamReader? get bodyParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.bodyParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : BodyParamReader(annotation);
  }
}
