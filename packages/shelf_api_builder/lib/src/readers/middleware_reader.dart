import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';

@internal
mixin MiddlewareReader {
  ConstantReader get constantReader;

  bool get hasMiddleware => !constantReader.read('middleware').isNull;

  Future<OpaqueConstant?> middleware(BuildStep buildStep) async {
    final middlewareReader = constantReader.read('middleware');
    return middlewareReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, middlewareReader.revive());
  }
}
