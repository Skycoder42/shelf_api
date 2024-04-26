import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
class EndpointGenerator extends GeneratorForAnnotation<FrogEndpoint> {
  final BuilderOptions _options;

  EndpointGenerator(this._options);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) =>
      '// Setup successful';
}
