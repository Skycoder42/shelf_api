import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzers/endpoint_analyzer.dart';
import 'builders/base_class_builder.dart';
import 'builders/on_request/on_request_builder.dart';
import 'readers/frog_endpoint_reader.dart';

@internal
class EndpointGenerator extends GeneratorForAnnotation<FrogEndpoint> {
  // ignore: unused_field
  final BuilderOptions _options;

  EndpointGenerator(this._options);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isFinal) {
      throw InvalidGenerationSourceError(
        'The $FrogEndpoint annotation can only be used on final classes',
        element: element,
      );
    }

    // ignore: unused_local_variable
    final frogEndpoint = FrogEndpointReader(annotation);

    // analyzer
    const endpointAnalyzer = EndpointAnalyzer();
    final endpoint = endpointAnalyzer.analyzeEndpoint(element);

    final library = Library(
      (b) => b
        ..ignoreForFile.add('type=lint')
        ..body.add(BaseClassBuilder(endpoint))
        ..body.add(OnRequestBuilder(endpoint)),
    );

    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final buffer = StringBuffer();
    library.accept(emitter, buffer);
    return buffer.toString();
  }
}
