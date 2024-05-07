import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../models/opaque_constant.dart';

@internal
mixin SerializableReader {
  ConstantReader get constantReader;

  bool get hasFromJson => !constantReader.read('fromJson').isNull;

  Future<OpaqueConstant?> fromJson(BuildStep buildStep) async {
    final fromJsonReader = constantReader.read('fromJson');
    return fromJsonReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, fromJsonReader.revive());
  }

  bool get hasToJson => !constantReader.read('toJson').isNull;

  Future<OpaqueConstant?> toJson(BuildStep buildStep) async {
    final toJsonReader = constantReader.read('toJson');
    return toJsonReader.isNull
        ? null
        : await OpaqueConstant.revived(buildStep, toJsonReader.revive());
  }
}
