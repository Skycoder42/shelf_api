import 'package:frog_api/frog_api.dart';

part 'index.g.dart';

@FrogEndpoint()
final class BasicEndpoint extends _$BasicEndpoint {
  BasicEndpoint(super.context);

  String get() => 'Hello, World!';
}
