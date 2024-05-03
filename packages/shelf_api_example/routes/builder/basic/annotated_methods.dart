import 'package:shelf_api/shelf_api.dart';

part 'annotated_methods.api.dart';

class SimpleJson {
  final int value;

  SimpleJson(this.value);

  Map<String, List<int>> toJson() => {
        'put': [11],
      };
}

@FrogEndpoint()
final class AnnotatedMethodsEndpoint extends _$AnnotatedMethodsEndpoint {
  AnnotatedMethodsEndpoint(super.context);

  @options
  int method1() => 42;

  @head
  Future<bool> method2() async => true;

  @get
  List<String> method3() => ['get'];

  @post
  List<int> method4() => [4, 2];

  @put
  Future<SimpleJson> method5() async => SimpleJson(11);

  @patch
  void method6() {}

  @delete
  Future<void> method7() async {}
}
