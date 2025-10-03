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
  required int statusCode,
  required Response Function(
    Object? body, {
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Encoding? encoding,
  })
  construct,
  Map<String, Object>? extraHeaders,
  bool hasBody = true,
  bool hasDefaultBody = false,
  bool withEncoding = true,
}) {
  group(name, () {
    test('correctly sets non body properties', () {
      const testHeaders = {'a': '1', 'b': '2'};
      const testContext = {'x': 42};

      final sut = construct(null, headers: testHeaders, context: testContext);
      expect(sut.statusCode, statusCode);
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
      expect(
        sut.headers,
        containsPair(HttpHeaders.contentTypeHeader, ContentType.text.mimeType),
      );
    });

    test('correctly sets text body with headers and encoding', () {
      const testBody = 'test-body';
      const testHeaders = {'a': '1'};
      final sut = construct(
        testBody,
        headers: testHeaders,
        encoding: withEncoding ? utf8 : null,
      );
      expect(sut.readAsString(), completion(testBody));
      expect(
        sut.headers,
        containsPair(
          HttpHeaders.contentTypeHeader,
          withEncoding
              ? ContentType.text.toString()
              : ContentType.text.mimeType,
        ),
      );
      expect(sut.headers, containsPair('a', '1'));
      for (final entry
          in extraHeaders?.entries ?? <MapEntry<String, Object>>[]) {
        expect(sut.headers, containsPair(entry.key, entry.value));
      }
    });

    test('correctly sets text stream body', () {
      const testBody = 'test-body';
      final sut = construct(Stream.value(testBody));
      expect(sut.readAsString(), completion(testBody));
      expect(
        sut.headers,
        containsPair(HttpHeaders.contentTypeHeader, ContentType.text.mimeType),
      );
    });

    test('correctly sets binary body', () {
      const testBody = [1, 2, 3, 4, 5];
      final sut = construct(Uint8List.fromList(testBody));
      expect(sut.read(), emitsInOrder([testBody, emitsDone]));
      expect(
        sut.headers,
        containsPair(
          HttpHeaders.contentTypeHeader,
          ContentType.binary.toString(),
        ),
      );
    });

    test('correctly sets binary stream body', () {
      const testBody = [1, 2, 3, 4, 5];
      final sut = construct(Stream.value(testBody));
      expect(sut.read(), emitsInOrder([testBody, emitsDone]));
      expect(
        sut.headers,
        containsPair(
          HttpHeaders.contentTypeHeader,
          ContentType.binary.toString(),
        ),
      );
    });

    test('correctly sets json body', () {
      const testBody1 = {'a': 1, 'b': true};
      final sut1 = construct(testBody1);
      expect(sut1.readAsString(), completion(json.encode(testBody1)));
      expect(
        sut1.headers,
        containsPair(HttpHeaders.contentTypeHeader, ContentType.json.mimeType),
      );

      const testBody2 = [1, 2, 3];
      final sut2 = construct(testBody2);
      expect(sut2.readAsString(), completion(json.encode(testBody2)));
      expect(
        sut2.headers,
        containsPair(HttpHeaders.contentTypeHeader, ContentType.json.mimeType),
      );
    });
  });
}

void main() {
  group('TResponse', () {
    group('constructor', () {
      _testResponseConstructor(
        'new',
        construct: (body, {context, headers, encoding}) => TResponse<dynamic>(
          HttpStatus.tooManyRequests,
          body: body,
          headers: headers,
          context: context,
          encoding: encoding,
        ),
        statusCode: HttpStatus.tooManyRequests,
      );

      _testResponseConstructor(
        'ok',
        construct: (body, {context, headers, encoding}) => TResponse.ok(
          body,
          headers: headers,
          context: context,
          encoding: encoding,
        ),
        statusCode: HttpStatus.ok,
      );

      _testResponseConstructor(
        'movedPermanently',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.movedPermanently(
              'test-location',
              body: body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.movedPermanently,
        extraHeaders: {HttpHeaders.locationHeader: 'test-location'},
      );

      _testResponseConstructor(
        'found',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.found(
              'test-location',
              body: body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.found,
        extraHeaders: {HttpHeaders.locationHeader: 'test-location'},
      );

      _testResponseConstructor(
        'seeOther',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.seeOther(
              'test-location',
              body: body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.seeOther,
        extraHeaders: {HttpHeaders.locationHeader: 'test-location'},
      );

      _testResponseConstructor(
        'notModified',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.notModified(headers: headers, context: context),
        statusCode: HttpStatus.notModified,
        hasBody: false,
      );

      _testResponseConstructor(
        'badRequest',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.badRequest(
              body: body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.badRequest,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'unauthorized',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.unauthorized(
              body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.unauthorized,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'forbidden',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.forbidden(
              body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.forbidden,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'notFound',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.notFound(
              body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.notFound,
        hasDefaultBody: true,
      );

      _testResponseConstructor(
        'internalServerError',
        construct: (body, {context, headers, encoding}) =>
            TResponse<dynamic>.internalServerError(
              body: body,
              headers: headers,
              context: context,
              encoding: encoding,
            ),
        statusCode: HttpStatus.internalServerError,
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
        construct: (body, {context, headers, encoding}) => testResponse.change(
          body: body,
          headers: {...testResponse.headers, ...?headers},
          context: context,
          encoding: encoding,
        ),
        statusCode: HttpStatus.ok,
        hasDefaultBody: true,
        withEncoding: false,
        extraHeaders: {'pre-change': '42'},
      );
    });
  });
}
