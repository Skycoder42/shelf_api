import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';

import 'endpoints/basic_endpoint.dart';
import 'endpoints/body_endpoint.dart';
import 'endpoints/middleware_endpoint.dart';
import 'endpoints/params_endpoint.dart';
import 'endpoints/response_endpoint.dart';
import 'endpoints/routing_endpoint.dart';

@ShelfApi(
  [
    BasicEndpoint,
    RootRoutingEndpoint,
    OpenRoutingEndpoint,
    ClosedRoutingEndpoint,
    SlashRoutingEndpoint,
    ResponseEndpoint,
    ParamsEndpoint,
    BodyEndpoint,
    MiddlewareEndpoint,
  ],
  basePath: '/api/v1/',
  middleware: apiMiddleware,
)
// ignore: unused_element for api definition
class _ExampleApi {}

Middleware apiMiddleware() =>
    (next) => (request) async {
      final response = await next(request);
      return response.change(
        headers: {
          'X-Api': 'shelf_api',
          'X-Middleware': ['Api', ...?response.headersAll['X-Middleware']],
        },
      );
    };
