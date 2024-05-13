import 'package:shelf/shelf.dart';
import 'package:shelf_api/shelf_api.dart';

class RootRoutingEndpoint extends ShelfEndpoint {
  RootRoutingEndpoint(super.request);

  @Head('/')
  Response headRoot() => Response.ok(
        null,
        headers: {
          'X-INFO': _logRequest(this.request),
        },
      );

  @Get('/')
  String getRoot() => _logRequest(this.request);

  @Get('/path/open')
  String getPathOpen() => _logRequest(this.request);

  @Get('/path/closed/')
  String getPathClosed() => _logRequest(this.request);
}

@ApiEndpoint('/open')
class OpenRoutingEndpoint extends ShelfEndpoint {
  OpenRoutingEndpoint(super.request);

  @Delete('/')
  String deleteRoot() => _logRequest(this.request);

  @Options('/path/open')
  String optionsPathOpen() => _logRequest(this.request);

  @Patch('/path/closed/')
  String patchPathClosed() => _logRequest(this.request);
}

@ApiEndpoint('/closed/')
class ClosedRoutingEndpoint extends ShelfEndpoint {
  ClosedRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => _logRequest(this.request);

  @Put('/path/open')
  String putPathOpen() => _logRequest(this.request);

  @ApiMethod(HttpMethod.trace, '/path/closed/')
  String tracePathClosed() => _logRequest(this.request);
}

@ApiEndpoint('/')
class SlashRoutingEndpoint extends ShelfEndpoint {
  SlashRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => _logRequest(this.request);

  @Post('/slash/open')
  String postSlashOpen() => _logRequest(this.request);

  @Post('/slash/closed/')
  String postSlashClosed() => _logRequest(this.request);
}

String _logRequest(Request request) =>
    '${request.method} ${request.requestedUri.path}';
