import 'dart:typed_data';

import 'package:frog_api/frog_api.dart';

part 'named_methods.api.dart';

@FrogEndpoint()
final class NamedMethodsEndpoint extends _$NamedMethodsEndpoint {
  NamedMethodsEndpoint(super.context);

  String options() => 'options';

  TResponse<String> head() => TResponse(body: 'head');

  Future<String> get() async => 'get';

  Future<TResponse<String>> post() async => TResponse(body: 'post');

  Uint8List put() => utf8.encode('put');

  Stream<String> patch() => Stream.value('patch');

  Stream<List<int>> delete() => Stream.value('delete').transform(utf8.encoder);
}
