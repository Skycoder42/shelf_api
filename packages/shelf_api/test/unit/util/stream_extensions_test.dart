import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/http_method.dart';
import 'package:shelf_api/src/util/stream_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ShelfApiStreamX', () {
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
          headers: {
            HttpHeaders.contentLengthHeader: '6',
          },
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

        test('throws if data is more than content length', () {
          final testStream = Stream.fromIterable([
            [1, 2],
            [3, 4, 5],
            [6, 7],
          ]);

          expect(
            () async => testStream.collect(request),
            throwsA(isA<HttpException>()),
          );
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
