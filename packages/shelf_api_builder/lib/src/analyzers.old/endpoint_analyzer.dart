// ignore_for_file: avoid_field_initializers_in_const_classes

import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import '../models/endpoint.dart';
import '../models/opaque_type.dart';
import 'methods_analyzer.dart';
import 'path_analyzer.dart';

@internal
class EndpointAnalyzer {
  final MethodsAnalyzer _methodsAnalyzer;
  final PathAnalyzer _pathAnalyzer;

  const EndpointAnalyzer()
      : _pathAnalyzer = const PathAnalyzer(),
        _methodsAnalyzer = const MethodsAnalyzer();

  Endpoint analyzeEndpoint(ClassElement clazz) => Endpoint(
        endpointType: OpaqueClassType(clazz),
        name: clazz.name,
        pathParameters: _pathAnalyzer.analyzePath(clazz),
        methods: _methodsAnalyzer.analyzeMethods(clazz),
      );
}
