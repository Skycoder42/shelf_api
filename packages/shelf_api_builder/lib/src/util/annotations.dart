import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class Annotations {
  Annotations._();

  static const Reference override = Reference('override');

  static final TypeReference restApi = TypeReference(
    (b) => b
      ..symbol = 'RestApi'
      ..url = 'package:retrofit/retrofit.dart',
  );

  static final TypeReference method = TypeReference(
    (b) => b
      ..symbol = 'Method'
      ..url = 'package:retrofit/retrofit.dart',
  );

  static final TypeReference dioResponseType = TypeReference(
    (b) => b
      ..symbol = 'DioResponseType'
      ..url = 'package:retrofit/retrofit.dart',
  );
}
