import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/endpoint.dart';
import '../util/types.dart';
import '../builders/base/spec_builder.dart';
import 'params_class_builder.dart';

@internal
final class BaseClassBuilder extends SpecBuilder<Class> {
  static const _contextRef = Reference('context');
  static const _refRef = Reference('ref');
  static const _pathParamsRef = Reference('pathParams');

  final Endpoint _endpoint;

  const BaseClassBuilder(this._endpoint);

  @override
  Class build() => Class(
        (b) => b
          ..name = '_\$${_endpoint.name}'
          ..abstract = true
          ..modifier = ClassModifier.base
          ..fields.addAll(_buildFields())
          ..constructors.add(_buildConstructor())
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

  Iterable<Field> _buildFields() sync* {
    yield Field(
      (b) => b
        ..name = _contextRef.symbol
        ..modifier = FieldModifier.final$
        ..type = Types.requestContext,
    );
    yield Field(
      (b) => b
        ..name = _refRef.symbol
        ..modifier = FieldModifier.final$
        ..type = Types.endpointRef,
    );

    if (_endpoint.pathParameters.isNotEmpty) {
      yield Field(
        (b) => b
          ..name = _pathParamsRef.symbol
          ..type = _paramsType,
      );
    }
  }

  Constructor _buildConstructor() => Constructor(
        (b) => b
          ..requiredParameters.addAll(_buildRequiredParameters())
          ..optionalParameters.add(
            Parameter(
              (b) => b
                ..name = _refRef.symbol!
                ..named = true
                ..type = Types.endpointRef.withNullable(true),
            ),
          )
          ..initializers.addAll(_buildInitializers()),
      );

  Iterable<Parameter> _buildRequiredParameters() sync* {
    yield Parameter(
      (b) => b
        ..name = _contextRef.symbol!
        ..toThis = true,
    );

    for (final pathParam in _endpoint.pathParameters) {
      yield Parameter(
        (b) => b
          ..name = pathParam.name
          ..type = Types.string,
      );
    }
  }

  Iterable<Code> _buildInitializers() sync* {
    if (_endpoint.pathParameters.isNotEmpty) {
      yield _pathParamsRef
          .assign(
            _paramsType.newInstance([
              for (final param in _endpoint.pathParameters) refer(param.name),
            ]),
          )
          .code;
    }

    yield _refRef.assign(_refRef.ifNullThen(_contextRef.property('ref'))).code;
  }

  TypeReference get _paramsType => TypeReference(
        (b) => b..symbol = ParamsClassBuilder.className(_endpoint.name),
      );
}
