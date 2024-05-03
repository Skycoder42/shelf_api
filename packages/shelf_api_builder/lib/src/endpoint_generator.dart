import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzers/api_class_analyzer.dart';
import 'builders/api_implementation_builder.dart';
import 'builders/api_mixin_builder.dart';
import 'readers/shelf_api_reader.dart';

@internal
class EndpointGenerator extends GeneratorForAnnotation<ShelfApi> {
  // ignore: unused_field
  final BuilderOptions _options;

  EndpointGenerator(this._options);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isAbstract) {
      throw InvalidGenerationSourceError(
        'The $ShelfApi annotation can only be used on abstract classes.',
        element: element,
      );
    }

    // analyzers
    final shelfApi = ShelfApiReader(annotation);
    const apiClassAnalyzer = ApiClassAnalyzer();
    final apiClass = apiClassAnalyzer.analyzeApiClass(element, shelfApi);

    // final paramsClassBuilder = ParamsClassBuilder(endpoint);
    final library = Library(
      (b) => b
        ..ignoreForFile.add('type=lint')
        ..ignoreForFile.add('invalid_use_of_protected_member')
        ..body.add(ApiMixinBuilder(apiClass))
        ..body.add(ApiImplementationBuilder(apiClass)),
      // ..body.addAll([
      //   if (paramsClassBuilder.shouldBuild) paramsClassBuilder,
      //   BaseClassBuilder(endpoint),
      //   OnRequestBuilder(endpoint),
      // ]),
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
