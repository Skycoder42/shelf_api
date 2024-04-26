import 'package:test/test.dart';

import 'test_helper.dart';

enum _Mode {
  singleton,
  // factory,
  // requestSingleton,
  // requestFactory,
}

void main() {
  late ExampleServer server;

  setUpAll(() async {
    server = await ExampleServer.start();
  });

  tearDownAll(() async {
    await server.stop();
  });

  Future<DateTime> getRiverpod(_Mode mode, [int? delaySeconds]) async {
    final timestamp = await server.get(
      Uri(
        path: '/riverpod',
        queryParameters: {
          'mode': mode.name,
          if (delaySeconds != null) 'delay': delaySeconds,
        },
      ),
    );
    return DateTime.parse(timestamp);
  }

  test('singleton returns constant timestamp value', () async {
    final now = DateTime.now();

    final timestamp = await getRiverpod(_Mode.singleton);

    expect(timestamp, isBetween(now, now.add(const Duration(seconds: 1))));
  });
}
