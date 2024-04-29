import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class Types {
  Types._();

  static final TypeReference requestContext = TypeReference(
    (b) => b
      ..symbol = 'RequestContext'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference request = TypeReference(
    (b) => b
      ..symbol = 'Request'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference response = TypeReference(
    (b) => b
      ..symbol = 'Response'
      ..url = 'package:dart_frog/dart_frog.dart',
  );

  static final TypeReference endpointRef = TypeReference(
    (b) => b
      ..symbol = 'EndpointRef'
      ..url = 'package:frog_api/frog_api.dart',
  );

  static TypeReference future(TypeReference type) => TypeReference(
        (b) => b
          ..symbol = 'Future'
          ..types.add(type),
      );
}

@internal
extension TypesX on TypeReference {
  TypeReference get nullable => TypeReference(
        (b) => b
          ..replace(this)
          ..isNullable = true,
      );
}
