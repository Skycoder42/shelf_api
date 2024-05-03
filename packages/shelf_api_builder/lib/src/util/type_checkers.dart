import 'dart:typed_data';

import 'package:shelf_api/shelf_api.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@internal
abstract base class TypeCheckers {
  static const list = TypeChecker.fromRuntime(List);

  static const map = TypeChecker.fromRuntime(Map);

  static const future = TypeChecker.fromRuntime(Future);

  static const stream = TypeChecker.fromRuntime(Stream);

  static const intList = TypeChecker.fromRuntime(List<int>);

  static const uint8List = TypeChecker.fromRuntime(Uint8List);

  static const formData = TypeChecker.fromRuntime(FormData);

  static const response = TypeChecker.fromRuntime(Response);
}
