// ignore_for_file: avoid_print in examples

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:shelf_router/shelf_router.dart';

import 'format_handler.dart';
import 'riverpod_request_handler.dart';

void main(List<String> args) async {
  final port = int.parse(args.firstOrNull ?? '8080');
  final router = Router()
    ..get('/riverpod', riverpodRequestHandler)
    ..get('/format', formatHandler);

  final app = const Pipeline()
      .addMiddleware(handleFormatExceptions())
      .addMiddleware(logRequests())
      .addMiddleware(rivershelf())
      .addHandler(router.call);

  final server = await serve(app, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');

  final signals = [
    ProcessSignal.sigint,
    if (!Platform.isWindows) ProcessSignal.sigterm,
  ];
  final subs = <StreamSubscription<ProcessSignal>>[];
  for (final signal in signals) {
    subs.add(
      signal.watch().listen((signal) {
        for (final sub in subs) {
          unawaited(sub.cancel());
        }
        print('Received $signal - terminating server');
        unawaited(server.close());
      }),
    );
  }
}
