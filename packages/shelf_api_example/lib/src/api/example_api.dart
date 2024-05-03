import 'package:shelf_api/shelf_api.dart';

import 'endpoints/basic_endpoint.dart';
import 'endpoints/routing_endpoint.dart';

part 'example_api.api.dart';

@ShelfApi([
  BasicEndpoint,
  RootRoutingEndpoint,
  OpenRoutingEndpoint,
  ClosedRoutingEndpoint,
  SlashRoutingEndpoint,
])
abstract class ExampleApi with _$ExampleApi {
  factory ExampleApi() = _ExampleApi;
}
