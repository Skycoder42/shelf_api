// ignore_for_file: discarded_futures

import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/format_exception_handler.dart';
import 'package:test/test.dart';

class FakeRequest extends Fake implements Request {}

class FakeResponse extends Fake implements Response {}

void main() {
  group('FormatExceptionHandlerMiddleware', () {
    final testRequest = FakeRequest();
    final testResponse = FakeResponse();

    late FormatExceptionHandlerMiddleware sut;

    setUp(() {
      sut = FormatExceptionHandlerMiddleware();
    });

    test('returns response as is', () {
      final sutHandler = sut(
        expectAsync1((request) {
          expect(request, same(testRequest));
          return testResponse;
        }),
      );
      expect(sutHandler(testRequest), completion(same(testResponse)));
    });

    test('returns badRequest if handler throws FormatException', () async {
      const testException = FormatException('test-message');
      final sutHandler = sut(
        expectAsync1((request) {
          expect(request, same(testRequest));
          throw testException;
        }),
      );
      final result = await sutHandler(testRequest);
      expect(result.statusCode, HttpStatus.badRequest);
      expect(result.readAsString(), completion(testException.message));
      expect(
        result.context,
        containsPair(formatExceptionOriginalExceptionKey, testException),
      );
      expect(
        result.context,
        containsPair(formatExceptionOriginalStackTraceKey, isA<StackTrace>()),
      );
    });
  });
}
