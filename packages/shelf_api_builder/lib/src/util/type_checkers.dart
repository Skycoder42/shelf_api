import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:source_gen/source_gen.dart';

@internal
abstract base class TypeCheckers {
  static const list = TypeChecker.typeNamed(List, inSdk: true);

  static const map = TypeChecker.typeNamed(Map, inSdk: true);

  static const dateTime = TypeChecker.typeNamed(DateTime, inSdk: true);

  static const future = TypeChecker.typeNamed(Future, inSdk: true);

  static const stream = TypeChecker.typeNamed(Stream, inSdk: true);

  static const intList = TypeChecker.typeNamed(List<int>, inSdk: true);

  static const uint8List = TypeChecker.typeNamed(Uint8List, inSdk: true);

  static const response = TypeChecker.typeNamed(Response, inPackage: 'shelf');

  static const tResponse = TypeChecker.typeNamed(
    TResponse,
    inPackage: 'shelf_api',
  );

  static const shelfApi = TypeChecker.typeNamed(
    ShelfApi,
    inPackage: 'shelf_api',
  );

  static const shelfEndpoint = TypeChecker.typeNamed(
    ShelfEndpoint,
    inPackage: 'shelf_api',
  );

  static const apiEndpoint = TypeChecker.typeNamed(
    ApiEndpoint,
    inPackage: 'shelf_api',
  );

  static const apiMethod = TypeChecker.typeNamed(
    ApiMethod,
    inPackage: 'shelf_api',
  );

  static const bodyParam = TypeChecker.typeNamed(
    BodyParam,
    inPackage: 'shelf_api',
  );

  static const pathParam = TypeChecker.typeNamed(
    PathParam,
    inPackage: 'shelf_api',
  );

  static const queryParam = TypeChecker.typeNamed(
    QueryParam,
    inPackage: 'shelf_api',
  );
}
