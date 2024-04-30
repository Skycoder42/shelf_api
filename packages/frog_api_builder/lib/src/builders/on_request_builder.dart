import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../readers/endpoint_methods_reader.dart';
import '../util/code/if.dart';
import '../util/code/switch.dart';
import '../util/constants.dart';
import '../util/types.dart';
import 'spec_builder.dart';

class _AsyncRef {
  bool isAsync = false;
}

@internal
final class OnRequestBuilder extends SpecBuilder<Method> {
  static const _contextRef = Reference(r'$context');
  static const _endpointRef = Reference(r'$endpoint');
  static const _bodyRef = Reference(r'$body');
  static const _queryRef = Reference(r'$query');

  final EndpointMethodsReader _endpointMethodsReader =
      const EndpointMethodsReader();

  final ClassElement _class;

  OnRequestBuilder(this._class);

  @override
  Method build() => Method(
        (b) {
          final asyncRef = _AsyncRef();
          b
            ..name = 'onRequest'
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = _contextRef.symbol!
                  ..type = Types.requestContext,
              ),
            )
            ..body = Block.of(_buildBody(asyncRef))
            ..modifier = asyncRef.isAsync ? MethodModifier.async : null
            ..returns = asyncRef.isAsync
                ? Types.future(Types.response)
                : Types.response;
        },
      );

  Iterable<Code> _buildBody(_AsyncRef asyncRef) sync* {
    final methods = _endpointMethodsReader.readMethods(_class);
    if (methods.isEmpty) {
      yield Types.response
          .newInstance(const [], {
            'statusCode': Types.httpStatus.property('notImplemented'),
          })
          .returned
          .statement;
      return;
    }

    yield declareFinal(_endpointRef.symbol!)
        .assign(Types.fromClass(_class).newInstance([_contextRef]))
        .statement;

    final switchCase = Switch(
      _contextRef.property('request').property('method'),
    )..defaultCase = Types.response
        .newInstance(const [], {
          'statusCode': Types.httpStatus.property('methodNotAllowed'),
        })
        .returned
        .statement;

    for (final MapEntry(key: httpMethod, value: endpointMethod)
        in methods.entries) {
      switchCase.addCase(
        Types.httpMethod.property(httpMethod.name),
        Block.of(_buildInvocation(endpointMethod, asyncRef)),
      );
    }

    yield switchCase;
  }

  Iterable<Code> _buildInvocation(
    EndpointMethod method,
    _AsyncRef asyncRef,
  ) sync* {
    yield* _buildBodyParamVariables(method.body, asyncRef);
    yield* _buildQueryParamVariables(method.queryParameters);

    var invocation = _endpointRef.property(method.name).call(
          _buildBodyParam(method.body),
          Map.fromEntries(_buildQueryParams(method)),
        );
    if (method.isAsync) {
      asyncRef.isAsync = true;
      invocation = invocation.awaited;
    }

    yield* _buildReturn(method, invocation);
  }

  Iterable<Code> _buildBodyParamVariables(
    EndpointMethodBody? methodBody,
    _AsyncRef asyncRef,
  ) sync* {
    if (methodBody == null) {
      return;
    }

    if (!methodBody.bodyType.isStream) {
      asyncRef.isAsync = true;
    }

    final requestRef = _contextRef.property('request');
    final bodyExpr = switch (methodBody.bodyType) {
      EndpointBodyType.text =>
        requestRef.property('body').call(const []).awaited,
      EndpointBodyType.binary => requestRef
          .property('bytes')
          .call(const [])
          .property('collect')
          .call(const [])
          .awaited,
      EndpointBodyType.textStream => requestRef
          .property('bytes')
          .call(const [])
          .property('transform')
          .call([Constants.utf8.property('decoder')]),
      EndpointBodyType.binaryStream =>
        requestRef.property('bytes').call(const []),
      EndpointBodyType.formData =>
        requestRef.property('formData').call(const []).awaited,
      EndpointBodyType.json ||
      EndpointBodyType.jsonList ||
      EndpointBodyType.jsonMap =>
        requestRef.property('json').call(const []).awaited,
    };

    yield declareFinal(_bodyRef.symbol!).assign(bodyExpr).statement;
  }

  List<Expression> _buildBodyParam(EndpointMethodBody? methodBody) {
    if (methodBody == null) {
      return const [];
    }

    if (!methodBody.bodyType.isJson) {
      return [_bodyRef];
    }

    final bodyType = Types.fromDartType(methodBody.paramType);
    final jsonType = switch (methodBody.jsonType) {
      final DartType jsonType => Types.fromDartType(jsonType),
      _ => null,
    };
    switch (methodBody.bodyType) {
      case EndpointBodyType.json:
        return [
          if (jsonType == null)
            _bodyRef.asA(bodyType)
          else
            bodyType.newInstanceNamed('fromJson', [_bodyRef.asA(jsonType)]),
        ];
      case EndpointBodyType.jsonList:
        return [
          if (jsonType == null)
            _bodyRef.asA(Types.list(bodyType))
          else
            _bodyRef
                .asA(Types.list())
                .property('cast')
                .call(const [], const {}, [jsonType])
                .property('map')
                .call([bodyType.property('fromJson')])
                .property('toList')
                .call(const []),
        ];
      case EndpointBodyType.jsonMap:
        return [
          if (jsonType == null)
            _bodyRef.asA(Types.map(keyType: Types.String$, valueType: bodyType))
          else
            _bodyRef
                .asA(Types.map())
                .property('cast')
                .call(const [], const {}, [Types.String$, jsonType])
                .property('mapValue')
                .call([bodyType.property('fromJson')]),
        ];
      // ignore: no_default_cases
      default:
        throw StateError(
          'Impossible value for bodyType: ${methodBody.bodyType}',
        );
    }
  }

  Iterable<Code> _buildQueryParamVariables(
    List<EndpointMethodParameter> queryParameters,
  ) sync* {
    if (queryParameters.isEmpty) {
      return;
    }

    yield declareFinal(_queryRef.symbol!)
        .assign(
          _contextRef
              .property('request')
              .property('url')
              .property('queryParameters'),
        )
        .statement;

    for (final param in queryParameters) {
      final paramName = '\$\$${param.name}';
      yield declareFinal(paramName)
          .assign(_queryRef.index(literalString(param.name, raw: true)))
          .statement;

      if (!param.optional) {
        yield If(
          refer(paramName).equalTo(literalNull),
          Types.response
              .newInstance(const [], {
                'statusCode': Types.httpStatus.property('badRequest'),
                'body': literalString(
                  'Missing required query parameter ${param.name}',
                  raw: true,
                ),
              })
              .returned
              .statement,
        );
      }
    }
  }

  Iterable<MapEntry<String, Expression>> _buildQueryParams(
    EndpointMethod method,
  ) sync* {
    for (final param in method.queryParameters) {
      final paramRef = refer('\$\$${param.name}');
      final convertExpression = param.type.isDartCoreString
          ? paramRef
          : Types.fromDartType(param.type, isNull: false)
              .newInstanceNamed('parse', [paramRef]);

      if (param.optional) {
        if (param.defaultValue case final String code) {
          yield MapEntry(
            param.name,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, CodeExpression(Code(code))),
          );
        } else {
          yield MapEntry(
            param.name,
            paramRef
                .notEqualTo(literalNull)
                .conditional(convertExpression, literalNull),
          );
        }
      } else {
        yield MapEntry(param.name, convertExpression);
      }
    }
  }

  Iterable<Code> _buildReturn(
    EndpointMethod method,
    Expression invocation,
  ) sync* {
    switch (method.returnType) {
      case EndpointReturnType.noContent:
        yield invocation.statement;
        yield Types.response
            .newInstance(const [], {
              'statusCode': Types.httpStatus.property('noContent'),
            })
            .returned
            .statement;
      case EndpointReturnType.text:
        yield Types.response
            .newInstance([], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.binary:
        yield Types.response
            .newInstanceNamed('bytes', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.textStream:
        yield Types.response
            .newInstanceNamed('stream', [], {
              'body': invocation
                  .property('transform')
                  .call([Constants.utf8.property('encoder')]),
            })
            .returned
            .statement;
      case EndpointReturnType.binaryStream:
        yield Types.response
            .newInstanceNamed('stream', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.json:
        yield Types.response
            .newInstanceNamed('json', [], {'body': invocation})
            .returned
            .statement;
      case EndpointReturnType.response:
        yield invocation.returned.statement;
    }
  }
}
