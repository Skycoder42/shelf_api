import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' hide MixinBuilder;
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'builders/mixin_builder.dart';
import 'readers/frog_endpoint_reader.dart';

@internal
class EndpointGenerator extends GeneratorForAnnotation<FrogEndpoint> {
  final BuilderOptions _options;

  EndpointGenerator(this._options);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The $FrogEndpoint annotation can only be used on classes',
        element: element,
      );
    }

    final frogEndpoint = FrogEndpointReader(annotation);
    final mixinBuilder = MixinBuilder(element, frogEndpoint);

    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final buffer = StringBuffer();
    mixinBuilder.accept(emitter, buffer);
    return buffer.toString();
  }
}
