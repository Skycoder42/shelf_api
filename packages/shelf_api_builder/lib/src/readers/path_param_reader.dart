import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';
import '../util/type_checkers.dart';

@internal
class PathParamReader {
  final ConstantReader constantReader;

  PathParamReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(PathParam)),
          'Can only apply PathParamReader on PathParam annotations.',
        );

  Future<OpaqueConstant> parse(BuildStep buildStep) async =>
      await OpaqueConstant.revived(
        buildStep,
        constantReader.read('parse').revive(),
      );
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
