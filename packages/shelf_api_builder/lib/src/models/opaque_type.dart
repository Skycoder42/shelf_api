import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import '../util/types.dart';
import 'serializable_type.dart';

@internal
sealed class OpaqueType {
  OpaqueType();

  SerializableType toSerializable(String reason) => switch (this) {
    OpaqueSerializableType(serializableType: final type) => type,
    _ => throw StateError(reason),
  };

  static Uri? uriForElement(BuildStep buildStep, Element2? element) {
    final sourceUriStr = Types.getUrlWithFallback(null, element);
    if (sourceUriStr == null) {
      return null;
    }

    final sourceUri = Uri.parse(sourceUriStr);
    if (sourceUri.isScheme('asset')) {
      final inputPath = posix.dirname(
        posix.join(sourceUri.pathSegments.first, buildStep.inputId.path),
      );
      final sourcePath = sourceUri.path;
      return Uri.file(
        posix.relative(sourcePath, from: inputPath),
        windows: false,
      );
    } else {
      return sourceUri;
    }
  }
}

@internal
class OpaqueSerializableType extends OpaqueType {
  final SerializableType serializableType;

  OpaqueSerializableType(this.serializableType);
}

@internal
class OpaqueDartType extends OpaqueType {
  final DartType dartType;
  final Uri? uri;

  OpaqueDartType(BuildStep buildStep, this.dartType)
    : uri = OpaqueType.uriForElement(buildStep, dartType.element3);
}

@internal
class OpaqueClassType extends OpaqueType {
  final ClassElement2 element;
  final Uri? uri;

  OpaqueClassType(BuildStep buildStep, this.element)
    : uri = OpaqueType.uriForElement(buildStep, element);
}

@internal
class OpaqueDynamicType extends OpaqueType {
  OpaqueDynamicType();
}
