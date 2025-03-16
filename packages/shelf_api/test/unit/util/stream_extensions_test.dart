// ignore_for_file: discarded_futures

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/http_method.dart';
import 'package:shelf_api/src/util/stream_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ShelfApiStreamX', () {
    test('registers callback that is invoked when stream is done', () {
      final testStream = Stream.fromIterable([1, 2, 3]);

      final sut = testStream.onFinished(expectAsync0(() {}));

      expect(sut, emitsInOrder([1, 2, 3, emitsDone]));
    });

    test('registers callback that is invoked when stream is canceled', () {
      final testController = StreamController<int>();
      addTearDown(testController.close);

      final sut = testController.stream.onFinished(expectAsync0(() {}));
      late StreamSubscription<int> sub;
      sub = sut.listen(
        expectAsync1(count: 2, (event) {
          if (event == 2) {
            sub.cancel();
          }
        }),
        onDone: () => fail('onDone should not be called'),
      );

      testController
        ..add(1)
        ..add(2);
    });
  });

  group('ShelfApiByteStreamX', () {
    group('collect', () {
      group('(without request)', () {
        test('merges stream into single byte array', () async {
          final testStream = Stream.fromIterable([
            [1, 2, 3],
            [4],
            [5, 6],
          ]);

          final result = await testStream.collect();
          expect(result, [1, 2, 3, 4, 5, 6]);
        });
      });

      group('(with request)', () {
        final request = Request(
          HttpMethod.get,
          Uri.http('localhost', '/'),
          headers: {HttpHeaders.contentLengthHeader: '6'},
        );

        test('merges stream into single byte array', () async {
          final testStream = Stream.fromIterable([
            [1, 2, 3],
            [4],
            [5, 6],
          ]);

          final result = await testStream.collect(request);
          expect(result, [1, 2, 3, 4, 5, 6]);
        });

        test('truncates data if data is more than content length', () async {
          final testStream = Stream.fromIterable([
            [1, 2],
            [3, 4, 5],
            [6, 7],
          ]);

          final result = await testStream.collect(request);
          expect(result, [1, 2, 3, 4, 5, 6]);
        });

        test('returns zero-initialized oversized array', () async {
          final testStream = Stream.fromIterable([
            [1, 2, 3],
            [4],
          ]);

          final result = await testStream.collect(request);
          expect(result, [1, 2, 3, 4, 0, 0]);
        });
      });
    });
  });
}
