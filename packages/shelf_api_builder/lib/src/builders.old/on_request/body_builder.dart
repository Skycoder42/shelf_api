import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
import '../../models/opaque_type.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';
import '../../builders/base/code_builder.dart';

@internal
final class BodyBuilder {
  static const _bodyRef = Reference(r'$body');

  final EndpointBody? _methodBody;
  final Reference _contextRef;

  const BodyBuilder(this._methodBody, this._contextRef);

  Code get variables => _methodBody != null
      ? _BodyVariableBuilder(_methodBody, _contextRef)
      : const Code('');

  List<Expression> get parameters =>
      _methodBody != null ? _BodyParamBuilder(_methodBody).build() : const [];
}

final class _BodyVariableBuilder extends CodeBuilder {
  final EndpointBody _methodBody;
  final Reference _contextRef;

  const _BodyVariableBuilder(this._methodBody, this._contextRef);

  @override
  Iterable<Code> build() sync* {
    final requestRef = _contextRef.property('request');
    final bodyExpr = switch (_methodBody.bodyType) {
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

    yield declareFinal(BodyBuilder._bodyRef.symbol!).assign(bodyExpr).statement;
  }
}

final class _BodyParamBuilder {
  final EndpointBody _methodBody;

  const _BodyParamBuilder(this._methodBody);

  List<Expression> build() {
    final paramType = Types.fromType(_methodBody.paramType);
    final jsonType = switch (_methodBody.jsonType) {
      final OpaqueType jsonType => Types.fromType(jsonType),
      _ => null,
    };

    switch (_methodBody.bodyType) {
      case EndpointBodyType.json:
        return _buildJson(paramType, jsonType);
      case EndpointBodyType.jsonList:
        return _buildList(paramType, jsonType);
      case EndpointBodyType.jsonMap:
        return _buildMap(paramType, jsonType);
      // ignore: no_default_cases
      default:
        return [BodyBuilder._bodyRef];
    }
  }

  List<Expression> _buildJson(
    TypeReference paramType,
    TypeReference? jsonType,
  ) =>
      [
        if (_methodBody.bodyFromJson case final String bodyFromJson)
          refer(bodyFromJson).call(const [BodyBuilder._bodyRef])
        else if (jsonType == null)
          BodyBuilder._bodyRef.asA(paramType)
        else if (_methodBody.isNullable)
          BodyBuilder._bodyRef.notEqualTo(literalNull).conditional(
                paramType.withNullable(false).newInstanceNamed(
                  'fromJson',
                  [BodyBuilder._bodyRef.asA(jsonType)],
                ),
                literalNull,
              )
        else
          paramType.newInstanceNamed(
            'fromJson',
            [BodyBuilder._bodyRef.asA(jsonType)],
          ),
      ];

  List<Expression> _buildList(
    TypeReference paramType,
    TypeReference? jsonType,
  ) =>
      [
        if (jsonType == null)
          BodyBuilder._bodyRef.asA(
            Types.list(paramType).withNullable(_methodBody.isNullable),
          )
        else
          BodyBuilder._bodyRef
              .asA(Types.list().withNullable(_methodBody.isNullable))
              .autoProperty('cast', _methodBody.isNullable)
              .call(const [], const {}, [jsonType])
              .property('map')
              .call([paramType.property('fromJson')])
              .property('toList')
              .call(const []),
      ];

  List<Expression> _buildMap(
    TypeReference paramType,
    TypeReference? jsonType,
  ) =>
      [
        if (jsonType == null)
          BodyBuilder._bodyRef.asA(
            Types.map(keyType: Types.string, valueType: paramType)
                .withNullable(_methodBody.isNullable),
          )
        else
          BodyBuilder._bodyRef
              .asA(Types.map().withNullable(_methodBody.isNullable))
              .autoProperty('cast', _methodBody.isNullable)
              .call(const [], const {}, [Types.string, jsonType])
              .property('mapValue')
              .call([paramType.property('fromJson')]),
      ];
}
