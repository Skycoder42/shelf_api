import 'package:shelf_api/shelf_api.dart';

class RootRoutingEndpoint extends ShelfEndpoint {
  RootRoutingEndpoint(super.request);

  @Get('/')
  String getRoot() => this.request.handlerPath;

  @Get('/path/open')
  String getOpenPath() => '${this.request.handlerPath}path/open';

  @Get('/path/closed/')
  String getClosedPath() => '${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/open')
class OpenRoutingEndpoint extends ShelfEndpoint {
  OpenRoutingEndpoint(super.request);

  @Get('/')
  String getRoot() => this.request.handlerPath;

  @Get('/path/open')
  String getOpenPath() => '${this.request.handlerPath}path/open';

  @Get('/path/closed/')
  String getClosedPath() => '${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/closed/')
class ClosedRoutingEndpoint extends ShelfEndpoint {
  ClosedRoutingEndpoint(super.request);

  @Get('/')
  String getRoot() => this.request.handlerPath;

  @Get('/path/open')
  String getOpenPath() => '${this.request.handlerPath}path/open';

  @Get('/path/closed/')
  String getClosedPath() => '${this.request.handlerPath}path/closed/';
}

@ApiEndpoint('/')
class SlashRoutingEndpoint extends ShelfEndpoint {
  SlashRoutingEndpoint(super.request);

  @Get('/')
  String getRoot() => throw Exception('THIS CAN NEVER BE REACHED');

  @Get('/slash/open')
  String getOpenPath() => 'SLASH${this.request.handlerPath}slash/open';

  @Get('/slash/closed/')
  String getClosedPath() => 'SLASH${this.request.handlerPath}slash/closed/';
}
