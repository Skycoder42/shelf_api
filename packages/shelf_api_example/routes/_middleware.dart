import 'package:shelf_api/shelf_api.dart';

Handler middleware(Handler handler) => handler.use(riverfrog());
