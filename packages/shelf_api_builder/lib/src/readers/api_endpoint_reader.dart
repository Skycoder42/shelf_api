import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';

@internal
class ApiEndpointReader {
  final ConstantReader constantReader;

  ApiEndpointReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(ApiEndpoint)),
          'Can only apply ApiEndpointReader on ApiEndpoint annotations.',
        );

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
