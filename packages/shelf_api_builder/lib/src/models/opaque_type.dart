import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'serializable_type.dart';

@internal
sealed class OpaqueType {
  OpaqueType();

  SerializableType toSerializable(String reason) => switch (this) {
    OpaqueSerializableType(serializableType: final type) => type,
    _ => throw StateError(reason),
  };

  static Uri? uriForElement(BuildStep buildStep, Element? element) {
    final sourceUri = element?.library?.uri;
    if (sourceUri == null) {
      return null;
    }

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

  static String? getUrlWithFallback(Uri? uri, Element? element) {
    final url =
        uri?.toString() ??
        element?.firstFragment.libraryFragment?.source.uri.toString();

    if (url == null) {
      return null;
    } else if (url.startsWith('dart:')) {
      return url.split('/').first;
    } else {
      return url;
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
    : uri = OpaqueType.uriForElement(buildStep, dartType.element);
}

@internal
class OpaqueClassType extends OpaqueType {
  final ClassElement element;
  final Uri? uri;

  OpaqueClassType(BuildStep buildStep, this.element)
    : uri = OpaqueType.uriForElement(buildStep, element);
}

@internal
class OpaqueDynamicType extends OpaqueType {
  OpaqueDynamicType();
}
