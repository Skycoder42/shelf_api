import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

@internal
abstract base class TypeCheckers {
  static const list = TypeChecker.fromRuntime(List);

  static const map = TypeChecker.fromRuntime(Map);

  static const future = TypeChecker.fromRuntime(Future);

  static const stream = TypeChecker.fromRuntime(Stream);

  static const intList = TypeChecker.fromRuntime(List<int>);

  static const uint8List = TypeChecker.fromRuntime(Uint8List);

  static const response = TypeChecker.fromRuntime(Response);

  static const tResponse = TypeChecker.fromRuntime(TResponse);

  static const shelfEndpoint = TypeChecker.fromRuntime(ShelfEndpoint);

  static const apiEndpoint = TypeChecker.fromRuntime(ApiEndpoint);

  static const apiMethod = TypeChecker.fromRuntime(ApiMethod);

  static const bodyParam = TypeChecker.fromRuntime(BodyParam);

  static const pathParam = TypeChecker.fromRuntime(PathParam);

  static const queryParam = TypeChecker.fromRuntime(QueryParam);
}
