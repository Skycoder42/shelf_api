// ignore_for_file: discarded_futures

import 'dart:io';
import 'dart:typed_data';

import 'package:shelf_api/src/api/t_response.dart';
import 'package:test/test.dart';

void main() {
  group('TResponse', () {
    const testHeaders = {'a': '1'};

    group('default constructor', () {
      const testStatus = HttpStatus.conflict;

      group('(text)', () {
        const testBody = 'test-body';

        test('maps body correctly', () {
          final sut = TResponse(
            body: testBody,
          );

          expect(sut.body(), completion(testBody));
          expect(sut.statusCode, HttpStatus.ok);
        });

        test('maps other properties', () {
          final sut = TResponse(
            statusCode: testStatus,
            body: testBody,
            headers: testHeaders,
          );

          expect(sut.statusCode, testStatus);
          expect(sut.headers, containsPair('a', '1'));
        });
      });

      group('(textStream)', () {
        final testBody = Stream.value('test-body');

        test('maps body correctly', () {
          final sut = TResponse(
            body: testBody,
          );

          expect(sut.body(), completion('test-body'));
          expect(sut.statusCode, HttpStatus.ok);
        });

        test('maps other properties', () {
          final sut = TResponse(
            statusCode: testStatus,
            body: testBody,
            headers: testHeaders,
          );

          expect(sut.statusCode, testStatus);
          expect(sut.headers, containsPair('a', '1'));
        });
      });

      group('(binary)', () {
        final testBody = Uint8List.fromList([1, 2, 3]);

        test('maps body correctly', () {
          final sut = TResponse(
            body: testBody,
          );

          expect(
            sut.bytes(),
            emitsInOrder([
              [1, 2, 3],
              emitsDone,
            ]),
          );
          expect(sut.statusCode, HttpStatus.ok);
        });

        test('maps other properties', () {
          final sut = TResponse(
            statusCode: testStatus,
            body: testBody,
            headers: testHeaders,
          );

          expect(sut.statusCode, testStatus);
          expect(sut.headers, containsPair('a', '1'));
        });
      });

      group('(binaryStream)', () {
        final testBody = Stream.value([1, 2, 3]);

        test('maps body correctly', () {
          final sut = TResponse(
            body: testBody,
          );

          expect(
            sut.bytes(),
            emitsInOrder([
              [1, 2, 3],
              emitsDone,
            ]),
          );
          expect(sut.statusCode, HttpStatus.ok);
        });

        test('maps other properties', () {
          final sut = TResponse(
            statusCode: testStatus,
            body: testBody,
            headers: testHeaders,
          );

          expect(sut.statusCode, testStatus);
          expect(sut.headers, containsPair('a', '1'));
        });
      });

      group('(json)', () {
        const testBody = {'a': 1, 'b': 2};

        test('maps body correctly', () {
          final sut = TResponse(
            body: testBody,
          );

          expect(sut.json(), completion(testBody));
          expect(sut.statusCode, HttpStatus.ok);
        });

        test('maps other properties', () {
          final sut = TResponse(
            statusCode: testStatus,
            body: testBody,
            headers: testHeaders,
          );

          expect(sut.statusCode, testStatus);
          expect(sut.headers, containsPair('a', '1'));
        });
      });
    });

    test('movedPermanently create moved permanently response', () {
      const testLocation = '/test/location';
      const testBody = 'test-body';

      final sut = TResponse.movedPermanently(
        location: testLocation,
        body: testBody,
        headers: testHeaders,
      );

      expect(sut.statusCode, HttpStatus.movedPermanently);
      expect(sut.body(), completion(testBody));
      expect(sut.headers, containsPair('a', '1'));
      expect(sut.headers, containsPair('Location', testLocation));
    });
  });
}
