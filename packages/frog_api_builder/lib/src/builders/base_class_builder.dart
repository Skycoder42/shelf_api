import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../util/types.dart';
import 'spec_builder.dart';

@internal
final class BaseClassBuilder extends SpecBuilder<Class> {
  static const _contextRef = Reference('context');
  static const _refRef = Reference('ref');

  final ClassElement _class;

  const BaseClassBuilder(this._class);

  @override
  Class build() => Class(
        (b) => b
          ..name = '_\$${_class.name}'
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
                      ..type = Types.endpointRef.nullable,
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
