import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_body.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_response.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';
import '../common/from_json_builder.dart';
import 'body_builder.dart';
import 'path_builder.dart';
import 'query_builder.dart';
import 'response_builder.dart';

@internal
final class MethodBodyBuilder extends CodeBuilder {
  final ApiClass _apiClass;
  final Endpoint _endpoint;
  final EndpointMethod _method;
  final Reference _dioRef;
  final Reference _optionsRef;
  final List<Reference> _extraParamsRefs;
  final bool _isRaw;

  const MethodBodyBuilder(
    this._apiClass,
    this._endpoint,
    this._method,
    this._dioRef,
    this._optionsRef,
    this._extraParamsRefs,
    this._isRaw,
  );

  @override
  Iterable<Code> build() sync* {
    final queryBuilder = QueryBuilder(_method.queryParameters);
    final invocation = _dioRef.property('request').call(
      [
        PathBuilder(_apiClass, _endpoint, _method),
      ],
      {
        if (_method.body case final EndpointBody body)
          'data': BodyBuilder(body),
        if (queryBuilder.hasParams) 'queryParameters': queryBuilder.build(),
        _optionsRef.symbol!.substring(1): _optionsRef
            .ifNullThen(Types.options.newInstance(const []))
            .parenthesized
            .property('copyWith')
            .call(const [], _options),
        for (final param in _extraParamsRefs) param.symbol!.substring(1): param,
      },
      [
        _responseDartType,
      ],
    );

    yield ResponseBuilder(_method.response, invocation.awaited, _isRaw);
  }

  Map<String, Expression> get _options => {
        'method': literalString(_method.httpMethod),
        'responseType': _responseType,
        if (_method.body?.contentTypes case [final firstContentType, ...])
          'contentType': literalString(firstContentType)
        else if (_method.body?.bodyType case final EndpointBodyType bodyType)
          'contentType': switch (bodyType) {
            EndpointBodyType.text ||
            EndpointBodyType.textStream =>
              literalString(ContentType.text.mimeType),
            EndpointBodyType.binary ||
            EndpointBodyType.binaryStream =>
              literalString(ContentType.binary.mimeType),
            EndpointBodyType.json => literalString(ContentType.json.mimeType),
          },
      };

  TypeReference get _responseDartType {
    switch (_method.response.responseType) {
      case EndpointResponseType.noContent:
        return Types.void$;
      case EndpointResponseType.text:
        return Types.string;
      case EndpointResponseType.binary:
        return Types.uint8List;
      case EndpointResponseType.textStream:
      case EndpointResponseType.binaryStream:
      case EndpointResponseType.dynamic:
        return Types.responseBody;
      case EndpointResponseType.json:
        return FromJsonBuilder(_method.response.serializableReturnType)
            .rawJsonType;
    }
  }

  Expression get _responseType => switch (_method.response.responseType) {
        EndpointResponseType.noContent => literalNull,
        EndpointResponseType.text => Types.responseType.property('plain'),
        EndpointResponseType.binary => Types.responseType.property('bytes'),
        EndpointResponseType.textStream ||
        EndpointResponseType.binaryStream ||
        EndpointResponseType.dynamic =>
          Types.responseType.property('stream'),
        EndpointResponseType.json => Types.responseType.property('json'),
      };
}
