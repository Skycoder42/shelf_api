import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';

@ApiEndpoint(
  '/middleware',
  middleware: MiddlewareEndpoint.endpointMiddleware,
)
class MiddlewareEndpoint extends ShelfEndpoint {
  MiddlewareEndpoint(super.request);

  @Get('/')
  Response get() => Response(
        HttpStatus.noContent,
        headers: {
          'X-Middleware': 'Response',
        },
      );

  static Middleware endpointMiddleware() => (next) => (request) async {
        final response = await next(request);
        return response.change(
          headers: {
            'X-Middleware': [
              'Endpoint',
              ...?response.headersAll['X-Middleware'],
            ],
            'X-Extra': 'extra',
          },
        );
      };
}
