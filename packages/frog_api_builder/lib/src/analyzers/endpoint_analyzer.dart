import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import '../models/endpoint.dart';
import '../models/opaque_type.dart';
import 'methods_analyzer.dart';

@internal
class EndpointAnalyzer {
  final MethodsAnalyzer _methodsAnalyzer;

  const EndpointAnalyzer([
    this._methodsAnalyzer = const MethodsAnalyzer(),
  ]);

  Endpoint analyzeEndpoint(ClassElement clazz) => Endpoint(
        endpointType: OpaqueClassType(clazz),
        name: clazz.name,
        methods: _methodsAnalyzer.analyzeMethods(clazz),
      );
}
