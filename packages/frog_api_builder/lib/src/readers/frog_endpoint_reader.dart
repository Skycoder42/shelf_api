import 'package:analyzer/dart/element/type.dart';
import 'package:frog_api/frog_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
class FrogEndpointReader {
  final ConstantReader constantReader;

  FrogEndpointReader(this.constantReader)
      : assert(
          constantReader
              .instanceOf(const TypeChecker.fromRuntime(FrogEndpoint)),
          'Can only apply FrogEndpointReader on FrogEndpoint annotations.',
        );

  Map<Symbol, DartType> get pathParams =>
      constantReader.read('pathParams').mapValue.map(
            (key, value) => MapEntry(
              ConstantReader(key).symbolValue,
              ConstantReader(value).typeValue,
            ),
          );
}
