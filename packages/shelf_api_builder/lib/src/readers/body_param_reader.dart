import 'package:analyzer/dart/element/element2.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'serializable_reader.dart';

@internal
class BodyParamReader with SerializableReader {
  @override
  final ConstantReader constantReader;

  BodyParamReader(this.constantReader) {
    if (!constantReader.instanceOf(TypeCheckers.bodyParam)) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply BodyParamReader on BodyParam annotations.',
      );
    }
  }

  List<String>? get contentTypes {
    final contentTypesReader = constantReader.read('contentTypes');
    return contentTypesReader.isNull
        ? null
        : contentTypesReader.listValue
              .map(ConstantReader.new)
              .map((r) => r.stringValue)
              .toList();
  }
}

@internal
extension BodyParamElementX on FormalParameterElement {
  BodyParamReader? get bodyParamAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.bodyParam.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : BodyParamReader(annotation);
  }
}
