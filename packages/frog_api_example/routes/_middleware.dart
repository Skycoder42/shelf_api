import 'package:dart_frog/dart_frog.dart';
import 'package:frog_api/frog_api.dart';
import 'package:riverpod/riverpod.dart';

ProviderContainer? _container;

Handler middleware(Handler handler) =>
    handler.use(riverfrog(_container ??= ProviderContainer()));
