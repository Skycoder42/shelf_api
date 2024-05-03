import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_helper/source_helper.dart';

import '../../models/api_class.dart';
import '../../models/endpoint.dart';
import '../../models/endpoint_method.dart';
import '../../models/endpoint_response.dart';
import '../../util/annotations.dart';
import '../../util/types.dart';
import '../base/spec_builder.dart';

@internal
final class ClientBuilder extends SpecBuilder<Class> {
  final ApiClass _apiClass;

  ClientBuilder(this._apiClass);

  @override
  Class build() => Class(
        (b) => b
          ..abstract = true
          ..name = _apiClass.clientName
          ..annotations.add(
            Annotations.restApi.newInstance(const []),
          )
          ..methods.addAll(_buildMethods()),
      );

  Iterable<Method> _buildMethods() sync* {
    for (final endpoint in _apiClass.endpoints) {
      for (final method in endpoint.methods) {
        yield Method(
          (b) => b
            ..name = _methodName(endpoint, method)
            ..returns = _returnType(method.response),
        );
      }
    }
  }

  String _methodName(Endpoint endpoint, EndpointMethod method) {
    var name = endpoint.name;
    name = name[0].toLowerCase() + name.substring(1);
    if (name.endsWith('Endpoint')) {
      name = name.substring(0, name.length - 8);
    }
    return name + method.name.pascal;
  }

  TypeReference _returnType(EndpointResponse response) {
    switch (response.responseType) {
      case EndpointResponseType.textStream:
      case EndpointResponseType.binaryStream:
        return Types.fromType(response.rawType);
      case EndpointResponseType.binary:
        return Types.future(Types.list(Types.int$));
      case EndpointResponseType.response:
      // TODO here
      // ignore: no_default_cases
      default:
        return Types.future(Types.fromType(response.rawType));
    }
  }
}
