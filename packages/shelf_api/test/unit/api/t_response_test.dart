// ignore_for_file: discarded_futures

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/t_response.dart';
import 'package:test/test.dart';

@isTestGroup
void _testResponseConstructor(
  String name, {
  required int expectedStatusCode,
  required Response Function(
    Object? body, {
    Map<String, Object>? headers,
    Map<String, Object>? context,
  }) construct,
  Map<String, Object>? extraHeaders,
  bool hasBody = true,
  bool hasDefaultBody = false,
}) {
  group(name, () {
    test('correctly sets non body properties', () {
      const testHeaders = {
        'a': '1',
        'b': '2',
      };
      const testContext = {'x': 42};

      final sut = construct(
        null,
        headers: testHeaders,
        context: testContext,
      );
      expect(sut.statusCode, expectedStatusCode);
      final allHeaders = {...testHeaders, ...?extraHeaders};
      for (final entry in allHeaders.entries) {
        expect(sut.headers, containsPair(entry.key, entry.value));
      }
      expect(sut.context, testContext);
    });

    if (!hasBody) {
      return;
    }

    if (hasDefaultBody) {
      test('correctly sets default body', () {
        final sut = construct(null);
        expect(sut.read(), emitsInOrder([isA<List<int>>(), emitsDone]));
      });
    } else {
      test('correctly sets null body', () {
        final sut = construct(null);
        expect(sut.read(), emitsDone);
      });
    }

    test('correctly sets text body', () {
      const testBody = 'test-body';
      final sut = construct(testBody);
      expect(sut.readAsString(), completion(testBody));
    });

    test('correctly sets text stream body', () {
      const testBody = 'test-body';
      final sut = construct(Stream.value(testBody));
      expect(sut.readAsString(), completion(testBody));
    });

    test('correctly sets binary body', () {
      const testBody = [1, 2, 3, 4, 5];
      final sut = construct(Uint8List.fromList(testBody));
      expect(sut.read(), emitsInOrder([testBody, emitsDone]));
    });

    test('correctly sets binary stream body', () {
      const testBody = [1, 2, 3, 4, 5];
      final sut = construct(Stream.value(testBody));
      expect(sut.read(), emitsInOrder([testBody, emitsDone]));
    });

    test('correctly sets json body', () {
      const testBody1 = {'a': 1, 'b': true};
      final sut1 = construct(testBody1);
      expect(sut1.readAsString(), completion(json.encode(testBody1)));

      const testBody2 = [1, 2, 3];
      final sut2 = construct(testBody2);
      expect(sut2.readAsString(), completion(json.encode(testBody2)));
    });
  });
}

void main() {
  group('TResponse', () {
    group('constructor', () {
      _testResponseConstructor(
        'new',
        construct: (body, {context, headers}) => TResponse(
          HttpStatus.tooManyRequests,
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.tooManyRequests,
      );

      _testResponseConstructor(
        'ok',
        construct: (body, {context, headers}) => TResponse.ok(
          body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.ok,
      );

      _testResponseConstructor(
        'movedPermanently',
        construct: (body, {context, headers}) => TResponse.movedPermanently(
          'test-location',
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.movedPermanently,
        extraHeaders: {
          HttpHeaders.locationHeader: 'test-location',
        },
      );

      _testResponseConstructor(
        'found',
        construct: (body, {context, headers}) => TResponse.found(
          'test-location',
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.found,
        extraHeaders: {
          HttpHeaders.locationHeader: 'test-location',
        },
      );

      _testResponseConstructor(
        'seeOther',
        construct: (body, {context, headers}) => TResponse.seeOther(
          'test-location',
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.seeOther,
        extraHeaders: {
          HttpHeaders.locationHeader: 'test-location',
        },
      );

      _testResponseConstructor(
        'notModified',
        construct: (body, {context, headers}) => TResponse.notModified(
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.notModified,
        hasBody: false,
      );

      _testResponseConstructor(
        'badRequest',
        construct: (body, {context, headers}) => TResponse.badRequest(
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.badRequest,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'unauthorized',
        construct: (body, {context, headers}) => TResponse.unauthorized(
          body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.unauthorized,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'forbidden',
        construct: (body, {context, headers}) => TResponse.forbidden(
          body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.forbidden,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'notFound',
        construct: (body, {context, headers}) => TResponse.notFound(
          body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.notFound,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'internalServerError',
        construct: (body, {context, headers}) => TResponse.internalServerError(
          body: body,
          headers: headers,
          context: context,
        ),
        expectedStatusCode: HttpStatus.internalServerError,
        hasDefaultBody: true,
      );
    });

    group('method', () {
      final testResponse = TResponse.ok(
        'pre-change-body',
        headers: {'pre-change': '42'},
      );

      _testResponseConstructor(
        'change',
        construct: (body, {context, headers}) => testResponse.change(
          body: body,
          headers: {...testResponse.headers, ...?headers},
          context: context,
        ),
        expectedStatusCode: HttpStatus.ok,
        hasDefaultBody: true,
        extraHeaders: {
          'pre-change': '42',
        },
      );
    });
  });
}
