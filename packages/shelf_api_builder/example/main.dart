// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_api/shelf_api.dart';
import 'example_api.api.dart';

void main(List<String> args) async {
  final port = int.parse(args.firstOrNull ?? '8080');

  final app = const Pipeline()
      .addMiddleware(handleFormatExceptions())
      .addMiddleware(logRequests())
      .addMiddleware(rivershelf())
      .addHandler(ExampleApi().call);

  final server = await serve(app, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');

  final signals = [
    ProcessSignal.sigint,
    if (!Platform.isWindows) ProcessSignal.sigterm,
  ];
  final subs = <StreamSubscription>[];
  for (final signal in signals) {
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
