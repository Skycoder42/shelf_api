import 'package:code_builder/code_builder.dart' hide MethodBuilder;
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'method_builder.dart';

@internal
final class ClientBuilder extends SpecBuilder<Class> {
  static const _dioRef = Reference('_dio');

  final ApiClass _apiClass;

  const ClientBuilder(this._apiClass);

  @override
  Class build() => Class(
        (b) => b
          ..name = _apiClass.clientName
          ..abstract = true
          ..fields.add(
            Field(
              (b) => b
                ..name = _dioRef.symbol
                ..modifier = FieldModifier.final$
                ..type = Types.dio,
            ),
          )
          ..methods.addAll(_buildMethods()),
      );

  Iterable<Method> _buildMethods() sync* {
    for (final endpoint in _apiClass.endpoints) {
      for (final method in endpoint.methods) {
        yield MethodBuilder(endpoint, method, _dioRef).build();
      }
    }
  }
}
