import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
import '../../models/opaque_constant.dart';
import '../../models/opaque_type.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';

@internal
final class BodyBuilder {
  static const _bodyRef = Reference(r'$body');

  final EndpointBody? _methodBody;
  final Reference _requestRef;

  const BodyBuilder(this._methodBody, this._requestRef);

  Code get variables => _methodBody != null
      ? _BodyVariableBuilder(_methodBody, _requestRef)
      : const Code('');

  Expression? get parameter =>
      _methodBody != null ? _BodyParamBuilder(_methodBody).build() : null;
}

final class _BodyVariableBuilder extends CodeBuilder {
  final EndpointBody _methodBody;
  final Reference _requestRef;

  const _BodyVariableBuilder(this._methodBody, this._requestRef);

  @override
  Iterable<Code> build() sync* {
    final bodyExpr = switch (_methodBody.bodyType) {
      EndpointBodyType.text =>
        _requestRef.property('readAsString').call(const []).awaited,
      EndpointBodyType.binary => _requestRef
          .property('read')
          .call(const [])
          .property('collect')
          .call([_requestRef])
          .awaited,
      EndpointBodyType.textStream => _requestRef
          .property('read')
          .call(const [])
          .property('transform')
          .call([Constants.utf8.property('decoder')]),
      EndpointBodyType.binaryStream =>
        _requestRef.property('read').call(const []),
      EndpointBodyType.json ||
      EndpointBodyType.jsonList ||
      EndpointBodyType.jsonMap =>
        Constants.json.property('decode').call([
          _requestRef.property('readAsString').call(const []).awaited,
        ]),
    };

    yield declareFinal(BodyBuilder._bodyRef.symbol!).assign(bodyExpr).statement;
  }
}

final class _BodyParamBuilder {
  final EndpointBody _methodBody;

  const _BodyParamBuilder(this._methodBody);

  Expression build() {
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
        return BodyBuilder._bodyRef;
    }
  }

  Expression _buildJson(
    TypeReference paramType,
    TypeReference? jsonType,
  ) {
    var checkNull = false;
    Expression paramExpr;
    if (_methodBody.fromJson case final OpaqueConstant fromJson) {
      checkNull = true;
      paramExpr =
          Constants.fromConstant(fromJson).call(const [BodyBuilder._bodyRef]);
    } else if (jsonType == null) {
      paramExpr = BodyBuilder._bodyRef.asA(paramType);
    } else {
      checkNull = true;
      paramExpr = paramType.withNullable(false).newInstanceNamed(
        'fromJson',
        [BodyBuilder._bodyRef.asA(jsonType)],
      );
    }

    if (checkNull && _methodBody.isNullable) {
      paramExpr = BodyBuilder._bodyRef.notEqualTo(literalNull).conditional(
            paramExpr,
            literalNull,
          );
    }

    return paramExpr;
  }

  Expression _buildList(
    TypeReference paramType,
    TypeReference? jsonType,
  ) {
    if (jsonType == null) {
      return BodyBuilder._bodyRef
          .asA(Types.list().withNullable(_methodBody.isNullable))
          .autoProperty('cast', _methodBody.isNullable)
          .call(const [], const {}, [paramType])
          .property('toList')
          .call(const []);
    } else {
      return BodyBuilder._bodyRef
          .asA(Types.list().withNullable(_methodBody.isNullable))
          .autoProperty('cast', _methodBody.isNullable)
          .call(const [], const {}, [jsonType])
          .property('map')
          .call([paramType.property('fromJson')])
          .property('toList')
          .call(const []);
    }
  }

  Expression _buildMap(
    TypeReference paramType,
    TypeReference? jsonType,
  ) {
    if (jsonType == null) {
      return BodyBuilder._bodyRef
          .asA(
            Types.map(keyType: Types.string)
                .withNullable(_methodBody.isNullable),
          )
          .autoProperty('cast', _methodBody.isNullable)
          .call(const [], const {}, [Types.string, paramType]);
    } else {
      return BodyBuilder._bodyRef
          .asA(
            Types.map(keyType: Types.string)
                .withNullable(_methodBody.isNullable),
          )
          .autoProperty('cast', _methodBody.isNullable)
          .call(const [], const {}, [Types.string, jsonType])
          .property('mapValue')
          .call([paramType.property('fromJson')]);
    }
  }
}
