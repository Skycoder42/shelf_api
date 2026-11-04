import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'opaque_type.dart';

@internal
// ignore: public_member_api_docs analyzer bug with primary constructors
sealed class const OpaqueConstant() {
  static Future<OpaqueConstant> revived(
    BuildStep buildStep,
    Revivable revivable,
  ) async {
    final assetId = AssetId.resolve(revivable.source, from: buildStep.inputId);
    final element = await buildStep.resolver.libraryFor(assetId);
    return RevivedOpaqueConstant._(
      revivable,
      OpaqueType.uriForElement(buildStep, element),
    );
  }
}

@internal
class RevivedOpaqueConstant._(final Revivable revivable, final Uri? source)
    extends OpaqueConstant;
