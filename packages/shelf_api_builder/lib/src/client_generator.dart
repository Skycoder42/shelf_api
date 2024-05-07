import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzers/api_class_analyzer.dart';
import 'builders/client/client_builder.dart';
import 'readers/shelf_api_reader.dart';

@internal
class ClientGenerator extends GeneratorForAnnotation<ShelfApi> {
  const ClientGenerator();

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
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
        ..directives.add(
          Directive.import(
            'package:shelf_api/shelf_api.dart',
            show: const ['ShelfApiMapX'],
          ),
        )
        ..body.add(ClientBuilder(apiClass)),
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
