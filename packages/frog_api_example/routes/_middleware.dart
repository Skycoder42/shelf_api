import 'package:frog_api/frog_api.dart';

Handler middleware(Handler handler) => handler.use(riverfrog());
