import 'package:shelf_api/shelf_api.dart';

class RootRoutingEndpoint extends ShelfEndpoint {
  RootRoutingEndpoint(super.request);

  @Head('/')
  Response headRoot() => Response.ok(
        null,
        headers: {
          'X-INFO': 'HEAD ${this.request.handlerPath}',
        },
      );

  @Get('/')
  String getRoot() => 'GET ${this.request.handlerPath}';

  @Get('/path/open')
  String getPathOpen() => 'GET ${this.request.handlerPath}path/open';

  @Get('/path/closed/')
  String getPathClosed() => 'GET ${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/open')
class OpenRoutingEndpoint extends ShelfEndpoint {
  OpenRoutingEndpoint(super.request);

  @Delete('/')
  String deleteRoot() => 'DELETE ${this.request.handlerPath}';

  @Options('/path/open')
  String optionsPathOpen() => 'OPTIONS ${this.request.handlerPath}path/open';

  @Patch('/path/closed/')
  String patchPathClosed() => 'PATCH ${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/closed/')
class ClosedRoutingEndpoint extends ShelfEndpoint {
  ClosedRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => 'POST ${this.request.handlerPath}';

  @Put('/path/open')
  String putPathOpen() => 'PUT ${this.request.handlerPath}path/open';

  @ApiMethod(HttpMethod.trace, '/path/closed/')
  String tracePathClosed() => 'TRACE ${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/')
class SlashRoutingEndpoint extends ShelfEndpoint {
  SlashRoutingEndpoint(super.request);

  @Post('/')
  String postRoot() => 'POST ${this.request.handlerPath}slash/open';

  @Post('/slash/open')
  String postSlashOpen() => 'POST ${this.request.handlerPath}slash/open';

  @Post('/slash/closed/')
  String postSlashClosed() => 'POST ${this.request.handlerPath}slash/closed/';
}
