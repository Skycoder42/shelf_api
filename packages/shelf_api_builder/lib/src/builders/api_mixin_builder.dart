import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../models/api_class.dart';
import '../util/types.dart';
import 'base/spec_builder.dart';

@internal
final class ApiMixinBuilder extends SpecBuilder<Mixin> {
  final ApiClass _apiClass;

  ApiMixinBuilder(this._apiClass);

  @override
  Mixin build() => Mixin(
        (b) => b
          ..name = _apiClass.mixinName
          ..methods.add(
            Method(
              (b) => b
                ..name = 'call'
                ..returns = Types.futureOr(Types.response)
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = 'request'
                      ..type = Types.request,
                  ),
                ),
            ),
          ),
      );
}
