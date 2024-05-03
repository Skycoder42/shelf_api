import 'package:shelf_api/shelf_api.dart';

import 'endpoints/basic_endpoint.dart';
import 'endpoints/body_endpoint.dart';
import 'endpoints/params_endpoint.dart';
import 'endpoints/response_endpoint.dart';
import 'endpoints/routing_endpoint.dart';

@ShelfApi([
  BasicEndpoint,
  RootRoutingEndpoint,
  OpenRoutingEndpoint,
  ClosedRoutingEndpoint,
  SlashRoutingEndpoint,
  ResponseEndpoint,
  ParamsEndpoint,
  BodyEndpoint,
])
// ignore: unused_element
class _ExampleApi {}
