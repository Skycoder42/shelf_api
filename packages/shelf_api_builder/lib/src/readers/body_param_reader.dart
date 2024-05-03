import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';
import '../util/type_checkers.dart';

@internal
class BodyParamReader {
  final ConstantReader constantReader;

  BodyParamReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(BodyParam)),
          'Can only apply BodyParamReader on BodyParam annotations.',
        );

  bool get hasFromJson => !constantReader.read('fromJson').isNull;

  Future<OpaqueConstant?> fromJson(BuildStep buildStep) async {
    final fromJsonReader = constantReader.read('fromJson');
    return fromJsonReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, fromJsonReader.revive());
  }
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
