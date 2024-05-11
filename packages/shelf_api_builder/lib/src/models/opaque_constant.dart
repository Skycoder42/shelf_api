import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'opaque_type.dart';

@internal
sealed class OpaqueConstant {
  const OpaqueConstant();

  static Future<OpaqueConstant> revived(
    BuildStep buildStep,
    Revivable revivable,
  ) async {
    final assetId = AssetId.resolve(
      revivable.source,
      from: buildStep.inputId,
    );
    final element = await buildStep.resolver.libraryFor(assetId);
    return RevivedOpaqueConstant._(
      revivable.accessor,
      OpaqueType.uriForElement(buildStep, element)!,
    );
  }
}

@internal
class RevivedOpaqueConstant extends OpaqueConstant {
  final String name;
  final Uri source;

  RevivedOpaqueConstant._(this.name, this.source);
}
