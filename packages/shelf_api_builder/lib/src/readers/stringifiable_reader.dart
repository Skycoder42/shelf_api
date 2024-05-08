import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';

@internal
mixin StringifiableReader {
  ConstantReader get constantReader;

  bool get hasParse => !constantReader.read('parse').isNull;

  Future<OpaqueConstant?> parse(BuildStep buildStep) async {
    final parseReader = constantReader.read('parse');
    return parseReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, parseReader.revive());
  }

  bool get hasStringify => !constantReader.read('stringify').isNull;

  Future<OpaqueConstant?> stringify(BuildStep buildStep) async {
    final stringifyReader = constantReader.read('stringify');
    return stringifyReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, stringifyReader.revive());
  }
}
