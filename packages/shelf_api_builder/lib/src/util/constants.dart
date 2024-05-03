import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/opaque_constant.dart';

@internal
abstract base class Constants {
  Constants._();

  static const utf8 = Reference('utf8', 'dart:convert');

  static const json = Reference('json', 'dart:convert');

  static Reference fromConstant(OpaqueConstant constant) => switch (constant) {
        final RevivedOpaqueConstant revived =>
          Reference(revived.name, revived.source.toString()),
      };
}
