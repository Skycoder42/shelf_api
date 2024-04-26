import 'package:frog_api/frog_api.dart';

part 'index.g.dart';

@FrogEndpoint()
class BasicEndpoint {
  String get() => 'Hello, World!';
}
