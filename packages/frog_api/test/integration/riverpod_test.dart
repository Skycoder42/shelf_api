import 'package:test/test.dart';

import 'test_helper.dart';

enum _Mode {
  singleton,
  factory,
  requestSingleton,
  requestFactory,
}

void main() {
  late ExampleServer server;

  setUpAll(() async {
    server = await ExampleServer.start();
  });

  tearDownAll(() async {
    await server.stop();
  });

  Future<DateTime> getRiverpod(_Mode mode, [Duration? delay]) async {
    final timestamp = await server.get(
      Uri(
        path: '/riverpod',
        queryParameters: {
          'mode': mode.name,
          if (delay != null) 'delay': delay.inMilliseconds.toString(),
        },
      ),
    );
    return DateTime.parse(timestamp);
  }

  test('singleton returns constant timestamp value', () async {
    final firstTimestamp = await getRiverpod(_Mode.singleton);
    await Future.delayed(const Duration(milliseconds: 100));
    final secondTimestamp = await getRiverpod(_Mode.singleton);

    expect(secondTimestamp, firstTimestamp);
  });

  group('factory', () {
    test('returns new timestamp for every request', () async {
      final firstTimestamp = await getRiverpod(_Mode.factory);
      await Future.delayed(const Duration(milliseconds: 100));
      final secondTimestamp = await getRiverpod(_Mode.factory);

      expect(secondTimestamp, isNot(firstTimestamp));
    });

    test('returns same timestamp if requests are run in parallel', () async {
      final [firstTimestamp, secondTimestamp, thirdTimestamp] =
          await Future.wait([
        getRiverpod(_Mode.factory, const Duration(milliseconds: 200)),
        Future.delayed(
          const Duration(milliseconds: 100),
          () => getRiverpod(_Mode.factory, const Duration(milliseconds: 300)),
        ),
        Future.delayed(
          const Duration(milliseconds: 300),
          () => getRiverpod(_Mode.factory),
        ),
      ]);

      expect(secondTimestamp, firstTimestamp);
      expect(thirdTimestamp, firstTimestamp);
    });
  });

  test('requestSingleton returns new timestamp for every request', () async {
    final [firstTimestamp, secondTimestamp] = await Future.wait([
      getRiverpod(_Mode.requestSingleton, const Duration(milliseconds: 200)),
      Future.delayed(
        const Duration(milliseconds: 100),
        () => getRiverpod(_Mode.requestSingleton),
      ),
    ]);

    expect(secondTimestamp, isNot(firstTimestamp));
  });

  test('requestFactory returns new timestamp for every request', () async {
    final [firstTimestamp, secondTimestamp] = await Future.wait([
      getRiverpod(_Mode.requestFactory, const Duration(milliseconds: 200)),
      Future.delayed(
        const Duration(milliseconds: 100),
        () => getRiverpod(_Mode.requestFactory),
      ),
    ]);

    expect(secondTimestamp, isNot(firstTimestamp));
  });
}
