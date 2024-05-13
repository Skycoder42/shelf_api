import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzers/api_class_analyzer.dart';
import 'builders/api/api_implementation_builder.dart';
import 'readers/shelf_api_reader.dart';

@internal
class EndpointGenerator extends GeneratorForAnnotation<ShelfApi> {
  final BuilderOptions options;

  const EndpointGenerator(this.options);

  bool get isEnabled => options.config['generateApi'] as bool? ?? true;

  @override
  Future<String?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (!isEnabled) {
      return null;
    }

    if (element is! ClassElement || !element.isPrivate) {
      throw InvalidGenerationSourceError(
        'The $ShelfApi annotation can only be used on private classes.',
        element: element,
      );
    }

    // analyzers
    final shelfApi = ShelfApiReader(annotation);
    final apiClassAnalyzer = ApiClassAnalyzer(buildStep);
    final apiClass = await apiClassAnalyzer.analyzeApiClass(element, shelfApi);

    final library = Library(
      (b) => b
        ..ignoreForFile.add('type=lint')
        ..ignoreForFile.add('invalid_use_of_protected_member')
        ..ignoreForFile.add('unused_import')
        ..directives.add(
          Directive.import('package:shelf_api/builder_utils.dart'),
        )
        ..directives.add(
          Directive.import(
            'package:shelf_router/shelf_router.dart',
            show: const ['RouterParams'],
          ),
        )
        ..body.add(ApiImplementationBuilder(apiClass)),
    );

    final emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final buffer = StringBuffer();
    library.accept(emitter, buffer);
    return buffer.toString();
  }
}
