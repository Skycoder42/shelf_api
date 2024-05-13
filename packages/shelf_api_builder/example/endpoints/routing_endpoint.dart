import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';

class RootRoutingEndpoint extends ShelfEndpoint {
  RootRoutingEndpoint(super.request);

  @Head('/')
  Response headRoot() => Response.ok(
        null,
        headers: {
          'X-INFO': _logRequest(request),
        },
      );

  @Get('/')
  String getRoot() => _logRequest(request);

  @Get('/path/open')
  String getPathOpen() => _logRequest(request);

  @Get('/path/closed/')
  String getPathClosed() => _logRequest(request);
}

@ApiEndpoint('/open')
class OpenRoutingEndpoint extends ShelfEndpoint {
  OpenRoutingEndpoint(super.request);

  @Delete('/')
  String deleteRoot() => _logRequest(request);

  @Options('/path/open')
  String optionsPathOpen() => _logRequest(request);

  @Patch('/path/closed/')
  String patchPathClosed() => _logRequest(request);
}

@ApiEndpoint('/closed/')
class ClosedRoutingEndpoint extends ShelfEndpoint {
  ClosedRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => _logRequest(request);

  @Put('/path/open')
  String putPathOpen() => _logRequest(request);

  @ApiMethod(HttpMethod.trace, '/path/closed/')
  String tracePathClosed() => _logRequest(request);
}

@ApiEndpoint('/')
class SlashRoutingEndpoint extends ShelfEndpoint {
  SlashRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => _logRequest(request);

  @Post('/slash/open')
  String postSlashOpen() => _logRequest(request);

  @Post('/slash/closed/')
  String postSlashClosed() => _logRequest(request);
}

String _logRequest(Request request) =>
    '${request.method} ${request.requestedUri.path}';
