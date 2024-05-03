// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_api/shelf_api.dart';
import 'package:shelf_api_example/src/api/example_api.dart';
import 'package:shelf_api_example/src/riverpod/riverpod_request_handler.dart';

void main(List<String> args) async {
  final port = int.parse(args.firstOrNull ?? '8080');
  final router = Router()
    ..get('/riverpod', riverpodRequestHandler)
    ..mount('/api', ExampleApi().call);

  final app =
      const Pipeline().addMiddleware(rivershelf()).addHandler(router.call);

  final server = await serve(app, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');

  final subs = <StreamSubscription>[];
  for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
    subs.add(
      signal.watch().listen((signal) {
        for (final sub in subs) {
          sub.cancel();
        }
        print('Received $signal - terminating server');
        server.close();
      }),
    );
  }
}
