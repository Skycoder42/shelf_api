// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

class ExampleServer {
  final Process _process;
  final Uri _baseUri;
  final HttpClient _client;

  ExampleServer._(this._process, int port)
    : _baseUri = Uri(scheme: 'http', host: 'localhost', port: port, path: '/'),
      _client = HttpClient();

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
          .listen((l) => print('ERR: $l'));

      final completer = Completer<void>();
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) {
            if (!completer.isCompleted && line.startsWith('Serving at')) {
              completer.complete(null);
            }
            return line;
          })
          .listen((l) => print('OUT: $l'));

      await completer.future.timeout(const Duration(seconds: 5));

      return ExampleServer._(process, port);
    } catch (_) {
      process.kill(ProcessSignal.sigkill);
      rethrow;
    }
  }

  Future<String> get(Uri url) async {
    final request = await _client.getUrl(_baseUri.resolveUri(url));
    final response = await request.close();
    expect(response.statusCode, HttpStatus.ok);
    return response.transform(utf8.decoder).join();
  }

  Future<HttpClientResponse> getRaw(Uri url, [String? body]) async {
    final request = await _client.getUrl(_baseUri.resolveUri(url));
    if (body != null) {
      final bytes = utf8.encode(body);
      request.headers.add(HttpHeaders.contentLengthHeader, bytes.length);
      request.add(bytes);
    }
    final response = await request.close();
    return response;
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
