import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../models/endpoint_body.dart';
import '../../models/opaque_constant.dart';
import '../../util/constants.dart';
import '../base/expression_builder.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
final class const BodyBuilder(final EndpointBody _body)
    extends ExpressionBuilder {
  static const bodyRef = Reference('body');

  @override
  Expression build() {
    switch (_body.bodyType) {
      case EndpointBodyType.text:
      case EndpointBodyType.binary:
      case EndpointBodyType.binaryStream:
        return bodyRef;
      case EndpointBodyType.textStream:
        return bodyRef.property('transform').call([
          Constants.utf8.property('encoder'),
        ]);
      case EndpointBodyType.json:
        final serializableType = _body.serializableParamType;
        if (serializableType.toJson case final OpaqueConstant toJson) {
          if (serializableType.isNullable) {
            return bodyRef
                .notEqualTo(literalNull)
                .conditional(
                  Constants.fromConstant(toJson).call([bodyRef]),
                  literalNull,
                );
          } else {
            return Constants.fromConstant(toJson).call([bodyRef]);
          }
        } else {
          return bodyRef;
        }
    }
  }
}
