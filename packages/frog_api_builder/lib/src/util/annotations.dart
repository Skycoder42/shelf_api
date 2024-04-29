import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@internal
abstract base class Annotations {
  Annotations._();

  static const Reference override = Reference('override');
}
