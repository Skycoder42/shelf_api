import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
import '../../models/opaque_constant.dart';
import '../../models/opaque_type.dart';
import '../../models/serializable_type.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';
import '../base/code_builder.dart';
import '../common/from_json_builder.dart';

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
      EndpointBodyType.json => Constants.json.property('decode').call([
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
    if (_methodBody.bodyType != EndpointBodyType.json) {
      return BodyBuilder._bodyRef;
    }

    final serializableType = _methodBody.paramType.toSerializable(
      'EndpointBody with bodyType json must hold a OpaqueSerializableType',
    );

    final rawJsonType = FromJsonBuilder(serializableType).rawJsonType;
    final castBody = rawJsonType == Types.dynamic$
        ? BodyBuilder._bodyRef
        : BodyBuilder._bodyRef.asA(rawJsonType);
    return switch (serializableType.wrapped) {
      Wrapped.none => _buildJson(serializableType, castBody),
      Wrapped.list => _buildList(serializableType, castBody),
      Wrapped.map => _buildMap(serializableType, castBody),
    };
  }

  Expression _buildJson(
    SerializableType type,
    Expression castBody,
  ) {
    var checkNull = false;
    Expression paramExpr;
    if (type.fromJson case final OpaqueConstant fromJson) {
      checkNull = true;
      paramExpr = Constants.fromConstant(fromJson).call([castBody]);
    } else if (type.jsonType != null) {
      checkNull = true;
      paramExpr = Types.fromType(type.dartType)
          .withNullable(false)
          .newInstanceNamed('fromJson', [castBody]);
    } else {
      paramExpr = castBody;
    }

    if (checkNull && type.isNullable) {
      paramExpr = BodyBuilder._bodyRef.notEqualTo(literalNull).conditional(
            paramExpr,
            literalNull,
          );
    }

    return paramExpr;
  }

  Expression _buildList(
    SerializableType type,
    Expression castBody,
  ) {
    if (type.jsonType case final OpaqueType jsonType) {
      return castBody
          .autoProperty('cast', type.isNullable)
          .call(const [], const {}, [Types.fromType(jsonType)])
          .property('map')
          .call([Types.fromType(type.dartType).property('fromJson')])
          .property('toList')
          .call(const []);
    } else {
      return castBody
          .autoProperty('cast', type.isNullable)
          .call(const [], const {}, [Types.fromType(type.dartType)])
          .property('toList')
          .call(const []);
    }
  }

  Expression _buildMap(
    SerializableType type,
    Expression castBody,
  ) {
    if (type.jsonType case final OpaqueType jsonType) {
      return castBody
          .autoProperty('cast', type.isNullable)
          .call(const [], const {}, [Types.string, Types.fromType(jsonType)])
          .property('mapValue')
          .call([Types.fromType(type.dartType).property('fromJson')]);
    } else {
      return castBody.autoProperty('cast', type.isNullable).call(
        const [],
        const {},
        [Types.string, Types.fromType(type.dartType)],
      );
    }
  }
}
