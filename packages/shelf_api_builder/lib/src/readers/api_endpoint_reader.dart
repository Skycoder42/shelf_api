import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'middleware_reader.dart';

@internal
class ApiEndpointReader with MiddlewareReader {
  @override
  final ConstantReader constantReader;

  ApiEndpointReader(this.constantReader) {
    if (!constantReader.instanceOf(TypeCheckers.apiEndpoint)) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply ApiEndpointReader on ApiEndpoint annotations.',
      );
    }
  }

  String get path => constantReader.read('path').stringValue;
}

@internal
extension ApiEndpointElementX on ClassElement {
  ApiEndpointReader? get apiEndpointAnnotation {
    final annotation = ConstantReader(
      TypeCheckers.apiEndpoint.firstAnnotationOf(this),
    );
    return annotation.isNull ? null : ApiEndpointReader(annotation);
  }
}
