import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_test_tools/tools.dart';
import 'package:test/test.dart';

class ExampleServer {
  final Process _process;
  final Uri _baseUri;
  final HttpClient _client;

  ExampleServer._(this._process, int port)
      : _baseUri = Uri(
          scheme: 'http',
          host: 'localhost',
          port: port,
          path: '/',
        ),
        _client = HttpClient();

  static Future<ExampleServer> start() async {
    final runnerTemp = Github.env.runnerTemp;
    final port = 8000 + Random.secure().nextInt(999);
    final process = await Process.start(
      runnerTemp.uri.resolve('frog-api-example-server.exe').toFilePath(),
      const [],
      environment: {
        'PORT': port.toString(),
      },
      mode: ProcessStartMode.inheritStdio,
    );

    return ExampleServer._(process, port);
  }

  Future<String> get(Uri url) async {
    final request = await _client.getUrl(_baseUri.resolveUri(url));
    final response = await request.close();
    expect(response.statusCode, HttpStatus.ok);
    return response.transform(utf8.decoder).join();
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
