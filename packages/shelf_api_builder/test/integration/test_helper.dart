import 'dart:io';
import 'dart:math';

import 'package:dart_test_tools/tools.dart';
import 'package:dio/dio.dart';
import 'package:shelf_api_example/src/api/example_api.client.dart';
import 'package:test/test.dart';

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
    final runnerTemp = Github.env.runnerTemp;
    final port = 8000 + Random.secure().nextInt(999);
    final process = await Process.start(
      runnerTemp.uri.resolve('shelf-api-example-server.exe').toFilePath(),
      [port.toString()],
      mode: ProcessStartMode.inheritStdio,
    );

    return ExampleServer._(process, port);
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
