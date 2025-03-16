import 'package:code_builder/code_builder.dart' hide MethodBuilder;
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint_response.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';
import 'method_builder.dart';

@internal
final class ClientBuilder extends SpecBuilder<Class> {
  static const _dioRef = Reference('_dio');
  static const _baseUrlRef = Reference('baseUrl');
  static const _baseOptionsRef = Reference('baseOptions');

  final ApiClass _apiClass;

  const ClientBuilder(this._apiClass);

  @override
  Class build() => Class(
    (b) =>
        b
          ..name = _apiClass.clientName
          ..fields.add(
            Field(
              (b) =>
                  b
                    ..name = _dioRef.symbol
                    ..modifier = FieldModifier.final$
                    ..type = Types.dio,
            ),
          )
          ..constructors.add(_buildDefaultConstructor())
          ..constructors.add(_buildOptionsConstructor())
          ..constructors.add(_buildDioConstructor())
          ..methods.addAll(_buildMethods())
          ..methods.add(_buildClose()),
  );

  Constructor _buildDefaultConstructor() => Constructor(
    (b) =>
        b
          ..requiredParameters.add(
            Parameter(
              (b) =>
                  b
                    ..name = _baseUrlRef.symbol!
                    ..type = Types.uri,
            ),
          )
          ..initializers.add(
            _dioRef
                .assign(
                  Types.dio.newInstance([
                    Types.baseOptions.newInstance(const [], {
                      'baseUrl': _baseUrlRef
                          .property('toString')
                          .call(const []),
                    }),
                  ]),
                )
                .code,
          ),
  );

  Constructor _buildOptionsConstructor() => Constructor(
    (b) =>
        b
          ..name = 'options'
          ..requiredParameters.add(
            Parameter(
              (b) =>
                  b
                    ..name = _baseOptionsRef.symbol!
                    ..type = Types.baseOptions,
            ),
          )
          ..initializers.add(
            _dioRef.assign(Types.dio.newInstance([_baseOptionsRef])).code,
          ),
  );

  Constructor _buildDioConstructor() => Constructor(
    (b) =>
        b
          ..name = 'dio'
          ..requiredParameters.add(
            Parameter(
              (b) =>
                  b
                    ..name = _dioRef.symbol!
                    ..toThis = true,
            ),
          ),
  );

  Iterable<Method> _buildMethods() sync* {
    for (final endpoint in _apiClass.endpoints) {
      for (final method in endpoint.methods) {
        final methodBuilder = MethodBuilder(
          _apiClass,
          endpoint,
          method,
          _dioRef,
        );
        yield methodBuilder.build();
        if (method.response.responseType != EndpointResponseType.dynamic) {
          yield methodBuilder.buildRaw();
        }
      }
    }
  }

  Method _buildClose() => Method(
    (b) =>
        b
          ..name = 'close'
          ..returns = Types.void$
          ..optionalParameters.add(
            Parameter(
              (b) =>
                  b
                    ..name = 'force'
                    ..type = Types.bool$
                    ..named = true
                    ..defaultTo = literalFalse.code,
            ),
          )
          ..body =
              _dioRef.property('close').call(const [], {
                'force': refer('force'),
              }).code,
  );
}
