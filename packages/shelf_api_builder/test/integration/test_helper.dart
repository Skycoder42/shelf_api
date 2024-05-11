import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:test/test.dart';

import '../../example/example_api.client.dart';

class ExampleServer {
  final Process _process;
  final Dio _client;

  ExampleServer._(this._process, int port)
      : _client = Dio(
          BaseOptions(
            baseUrl: Uri(
              scheme: 'http',
              host: 'localhost',
              port: port,
              path: '/',
            ).toString(),
          ),
        );

  ExampleApiClient get apiClient => ExampleApiClient.dio(_client);

  static Future<ExampleServer> start() async {
    final port = 8000 + Random.secure().nextInt(999);
    final process = await Process.start('dart', [
      'run',
      'example/main.dart',
      port.toString(),
    ]);

    try {
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((l) => printOnFailure('ERR: $l'));

      final completer = Completer<void>();
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) {
        if (!completer.isCompleted && line.startsWith('Serving at')) {
          completer.complete(null);
        }
        return line;
      }).listen((l) => printOnFailure('OUT: $l'));

      await completer.future.timeout(const Duration(seconds: 5));

      return ExampleServer._(process, port);

      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      process.kill(ProcessSignal.sigkill);
      rethrow;
    }
  }

  Future<void> stop() async {
    _client.close(force: true);

    expect(_process.kill(), isTrue);
    await _process.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        expect(_process.kill(ProcessSignal.sigkill), isTrue);
        return 0;
      },
    );
  }
}
