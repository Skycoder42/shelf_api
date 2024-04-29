import 'package:analyzer/dart/element/element.dart';
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
class FrogMethodReader {
  final ConstantReader constantReader;

  FrogMethodReader(this.constantReader)
      : assert(
          constantReader.instanceOf(const TypeChecker.fromRuntime(FrogMethod)),
          'Can only apply FrogMethodReader on FrogEndpoint annotations.',
        );

  HttpMethod get method => HttpMethod.values.singleWhere(
        (e) =>
            e.value == constantReader.read('method').read('value').stringValue,
      );
}

@internal
extension FrogMethodElementX on MethodElement {
  FrogMethodReader? get frogMethodAnnotation {
    final annotation = ConstantReader(
      const TypeChecker.fromRuntime(FrogMethod).firstAnnotationOfExact(this),
    );
    return annotation.isNull ? null : FrogMethodReader(annotation);
  }
}
