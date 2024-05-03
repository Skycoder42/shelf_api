import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';
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

  bool get hasToJson => !constantReader.read('toJson').isNull;

  Future<OpaqueConstant?> toJson(BuildStep buildStep) async {
    final toJsonReader = constantReader.read('toJson');
    return toJsonReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, toJsonReader.revive());
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
