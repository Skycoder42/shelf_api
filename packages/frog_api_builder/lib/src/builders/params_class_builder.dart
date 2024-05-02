import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/endpoint.dart';
import '../util/types.dart';
import 'base/spec_builder.dart';

@internal
final class ParamsClassBuilder extends SpecBuilder<Class> {
  final Endpoint _endpoint;

  const ParamsClassBuilder(this._endpoint);

  bool get shouldBuild => _endpoint.pathParameters.isNotEmpty;

  @override
  Class build() => Class(
        (b) => b
          ..name = '_\$${_endpoint.name}PathParams'
          ..modifier = ClassModifier.final$
          ..fields.addAll(_buildFields())
          ..constructors.add(_buildConstructor()),
      );

  Iterable<Field> _buildFields() sync* {
    for (final param in _endpoint.pathParameters) {
      yield Field(
        (b) => b
          ..name = param.name
          ..modifier = FieldModifier.final$
          ..type = Types.string,
      );
    }
  }

  Constructor _buildConstructor() => Constructor(
        (b) => b
          ..constant = true
          ..requiredParameters.addAll([
            for (final param in _endpoint.pathParameters)
              Parameter(
                (b) => b
                  ..name = param.name
                  ..toThis = true,
              ),
          ]),
      );
}
