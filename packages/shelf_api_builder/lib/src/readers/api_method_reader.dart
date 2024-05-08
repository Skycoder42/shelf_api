import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'serializable_reader.dart';

@internal
class ApiMethodReader with SerializableReader {
  @override
  final ConstantReader constantReader;

  ApiMethodReader(this.constantReader) {
    if (!constantReader.instanceOf(const TypeChecker.fromRuntime(ApiMethod))) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply ApiMethodReader on ApiMethod annotations.',
      );
    }
  }

  String get method => constantReader.read('method').stringValue;

  String get path => constantReader.read('path').stringValue;
}

@internal
extension ApiMethodElementX on MethodElement {
  ApiMethodReader? get apiMethodAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.apiMethod.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : ApiMethodReader(annotation);
  }
}
