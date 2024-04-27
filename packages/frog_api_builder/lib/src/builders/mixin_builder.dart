import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../readers/frog_endpoint_reader.dart';
import 'spec_builder.dart';

@internal
final class MixinBuilder extends SpecBuilder<Mixin> {
  final ClassElement _class;
  final FrogEndpointReader _frogEndpoint;

  const MixinBuilder(this._class, this._frogEndpoint);

  @override
  Mixin build() => Mixin(
        (b) => b..name = '_\$${_class.name}',
      );
}
