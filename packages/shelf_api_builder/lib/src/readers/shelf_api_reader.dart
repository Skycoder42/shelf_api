import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../util/type_checkers.dart';
import 'middleware_reader.dart';

@internal
class ShelfApiReader with MiddlewareReader {
  @override
  final ConstantReader constantReader;

  ShelfApiReader(this.constantReader) {
    if (!constantReader.instanceOf(TypeCheckers.shelfApi)) {
      throw ArgumentError.value(
        constantReader,
        'constantReader',
        'Can only apply ShelfApiReader on ShelfApi annotations.',
      );
    }
  }

  List<DartType> get endpoints => constantReader
      .read('endpoints')
      .listValue
      .map(ConstantReader.new)
      .map((r) => r.typeValue)
      .toList();

  String? get basePath {
    final basePathReader = constantReader.read('basePath');
    return basePathReader.isNull ? null : basePathReader.stringValue;
  }
}
