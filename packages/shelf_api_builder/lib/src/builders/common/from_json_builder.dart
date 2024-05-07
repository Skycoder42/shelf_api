import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/opaque_type.dart';
import '../../models/serializable_type.dart';
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
        Wrapped.map => Types.map(keyType: Types.string)
            .withNullable(_serializableType.isNullable),
      };
    }
  }
}
