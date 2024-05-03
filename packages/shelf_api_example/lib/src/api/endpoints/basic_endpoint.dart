import 'package:shelf_api/shelf_api.dart';

@ApiEndpoint('/basic')
class BasicEndpoint extends ShelfEndpoint {
  BasicEndpoint(super.request);

  @Get('/')
  String get() => 'Hello, World!';
}
