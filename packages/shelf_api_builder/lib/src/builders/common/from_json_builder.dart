import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/opaque_constant.dart';
import '../../models/opaque_type.dart';
import '../../models/serializable_type.dart';
import '../../util/constants.dart';
import '../../util/extensions/code_builder_extensions.dart';
import '../../util/types.dart';

@internal
class FromJsonBuilder {
  final SerializableType _serializableType;

  FromJsonBuilder(this._serializableType);

  TypeReference get rawJsonType {
    if (_serializableType.fromJson != null) {
      return Types.dynamic$;
    } else {
      return switch (_serializableType.wrapped) {
        Wrapped.none => switch (_serializableType.jsonType) {
          final OpaqueType jsonType => Types.fromType(jsonType),
          _ => Types.fromType(_serializableType.dartType),
        },
        Wrapped.list => Types.list().withNullable(_serializableType.isNullable),
        Wrapped.map => Types.map(
          keyType: Types.string,
        ).withNullable(_serializableType.isNullable),
      };
    }
  }

  Expression buildFromJson(Expression jsonBody) => switch (_serializableType
      .wrapped) {
    Wrapped.none => _buildJson(jsonBody),
    Wrapped.list => _buildList(jsonBody),
    Wrapped.map => _buildMap(jsonBody),
  };

  Expression _buildJson(Expression jsonBody) {
    var checkNull = false;
    Expression paramExpr;
    if (_serializableType.fromJson case final OpaqueConstant fromJson) {
      checkNull = true;
      paramExpr = Constants.fromConstant(fromJson).call([jsonBody]);
    } else if (_serializableType.jsonType != null) {
      checkNull = true;
      paramExpr = Types.fromType(
        _serializableType.dartType,
      ).withNullable(false).newInstanceNamed('fromJson', [jsonBody]);
    } else {
      paramExpr = jsonBody;
    }

    if (checkNull && _serializableType.isNullable) {
      paramExpr = jsonBody
          .notEqualTo(literalNull)
          .conditional(paramExpr, literalNull);
    }

    return paramExpr;
  }

  Expression _buildList(Expression jsonBody) {
    if (_serializableType.jsonType case final OpaqueType jsonType) {
      return jsonBody
          .autoProperty('cast', _serializableType.isNullable)
          .call(const [], const {}, [Types.fromType(jsonType)])
          .property('map')
          .call([
            Types.fromType(_serializableType.dartType).property('fromJson'),
          ])
          .property('toList')
          .call(const []);
    } else {
      return jsonBody
          .autoProperty('cast', _serializableType.isNullable)
          .call(const [], const {}, [
            Types.fromType(_serializableType.dartType),
          ])
          .property('toList')
          .call(const []);
    }
  }

  Expression _buildMap(Expression jsonBody) {
    if (_serializableType.jsonType case final OpaqueType jsonType) {
      return jsonBody
          .autoProperty('cast', _serializableType.isNullable)
          .call(const [], const {}, [Types.string, Types.fromType(jsonType)])
          .property('mapValue')
          .call([
            Types.fromType(_serializableType.dartType).property('fromJson'),
          ]);
    } else {
      return jsonBody.autoProperty('cast', _serializableType.isNullable).call(
        const [],
        const {},
        [Types.string, Types.fromType(_serializableType.dartType)],
      );
    }
  }
}
