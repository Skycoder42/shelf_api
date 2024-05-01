import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/endpoint.dart';
import '../util/types.dart';
import 'base/spec_builder.dart';

@internal
final class BaseClassBuilder extends SpecBuilder<Class> {
  static const _contextRef = Reference('context');
  static const _refRef = Reference('ref');

  final Endpoint _endpoint;

  const BaseClassBuilder(this._endpoint);

  @override
  Class build() => Class(
        (b) => b
          ..name = '_\$${_endpoint.name}'
          ..abstract = true
          ..modifier = ClassModifier.base
          ..fields.add(
            Field(
              (b) => b
                ..name = _contextRef.symbol
                ..modifier = FieldModifier.final$
                ..type = Types.requestContext,
            ),
          )
          ..fields.add(
            Field(
              (b) => b
                ..name = _refRef.symbol
                ..modifier = FieldModifier.final$
                ..type = Types.endpointRef,
            ),
          )
          ..constructors.add(
            Constructor(
              (b) => b
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = _contextRef.symbol!
                      ..toThis = true,
                  ),
                )
                ..optionalParameters.add(
                  Parameter(
                    (b) => b
                      ..name = _refRef.symbol!
                      ..named = true
                      ..type = Types.endpointRef.withNullable(true),
                  ),
                )
                ..initializers.add(
                  _refRef
                      .assign(_refRef.ifNullThen(_contextRef.property('ref')))
                      .code,
                ),
            ),
          )
          ..methods.add(
            Method(
              (b) => b
                ..name = 'request'
                ..type = MethodType.getter
                ..returns = Types.request
                ..body = _contextRef.property('request').code,
            ),
          ),
      );
}
