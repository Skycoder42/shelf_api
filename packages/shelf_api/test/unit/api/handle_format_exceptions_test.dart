import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/handle_format_exceptions.dart';
import 'package:test/test.dart';

class FakeRequest extends Fake implements Request {}

class FakeResponse extends Fake implements Response {}

void main() {
  group('FormatExceptionHandlerMiddleware', () {
    final testRequest = FakeRequest();
    final testResponse = FakeResponse();

    late Middleware sut;

    setUp(() {
      sut = handleFormatExceptions();
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
        containsPair(handleFormatExceptionsOriginalExceptionKey, testException),
      );
      expect(
        result.context,
        containsPair(
          handleFormatExceptionsOriginalStackTraceKey,
          isA<StackTrace>(),
        ),
      );
    });
  });
}
