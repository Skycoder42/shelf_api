import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';

@internal
class ApiMethodReader {
  final ConstantReader constantReader;

  ApiMethodReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(ApiMethod)),
          'Can only apply ApiMethodReader on ApiMethod annotations.',
        );

  String get method => constantReader.read('method').stringValue;

  String get path => constantReader.read('path').stringValue;

  String? get bodyFromJson {
    final bodyFromJsonReader = constantReader.read('bodyFromJson');
    return bodyFromJsonReader.isNull
        ? null
        : bodyFromJsonReader.revive().accessor;
  }

  String? get toJson {
    final toJsonReader = constantReader.read('toJson');
    return toJsonReader.isNull ? null : toJsonReader.revive().accessor;
  }
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
