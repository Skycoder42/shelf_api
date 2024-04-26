import 'package:dart_frog/dart_frog.dart';
import 'package:frog_api/frog_api.dart';

Handler middleware(Handler handler) => handler.use(riverfrog());
