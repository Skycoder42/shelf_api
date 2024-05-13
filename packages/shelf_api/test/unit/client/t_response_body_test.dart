import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shelf_api/src/api/http_method.dart';
import 'package:shelf_api/src/client/t_response_body.dart';
import 'package:test/test.dart';

void main() {
  group('TResponseBody', () {
    const testData = 42;
    const testStatusCode = HttpStatus.ok;
    const testStatusMessage = 'HTTP OK';
    const testIsRedirect = true;
    final testRedirects = [
      RedirectRecord(HttpStatus.movedPermanently, HttpMethod.get, Uri()),
    ];
    final testHeaders = Headers.fromMap(const {
      'a': ['1'],
      'b': ['4', '2'],
    });

    test('default constructor', () {
      final sut = TResponseBody(
        data: testData,
        statusCode: testStatusCode,
        statusMessage: testStatusMessage,
        isRedirect: testIsRedirect,
        redirects: testRedirects,
        headers: testHeaders,
      );

      expect(sut.data, testData);
      expect(sut.statusCode, testStatusCode);
      expect(sut.statusMessage, testStatusMessage);
      expect(sut.isRedirect, testIsRedirect);
      expect(sut.redirects, testRedirects);
      expect(sut.headers.map, testHeaders.map);
    });

    test('fromResponse constructor', () {
      final sut = TResponseBody.fromResponse(
        Response(
          data: 'test',
          requestOptions: RequestOptions(),
          statusCode: testStatusCode,
          statusMessage: testStatusMessage,
          headers: testHeaders,
          isRedirect: testIsRedirect,
          redirects: testRedirects,
        ),
        testData,
      );

      expect(sut.data, testData);
      expect(sut.statusCode, testStatusCode);
      expect(sut.statusMessage, testStatusMessage);
      expect(sut.isRedirect, testIsRedirect);
      expect(sut.redirects, testRedirects);
      expect(sut.headers.map, testHeaders.map);
    });

    test('fromResponse constructor', () {
      final sut = TResponseBody.fromResponseBody(
        ResponseBody(
          Stream.value(Uint8List.fromList([1, 2, 3])),
          testStatusCode,
          statusMessage: testStatusMessage,
          headers: testHeaders.map,
          isRedirect: testIsRedirect,
          redirects: testRedirects,
        ),
        testData,
      );

      expect(sut.data, testData);
      expect(sut.statusCode, testStatusCode);
      expect(sut.statusMessage, testStatusMessage);
      expect(sut.isRedirect, testIsRedirect);
      expect(sut.redirects, testRedirects);
      expect(sut.headers.map, testHeaders.map);
    });

    group('contentLength', () {
      test('returns parsed header value', () {
        final sut = TResponseBody(
          data: testData,
          statusCode: testStatusCode,
          statusMessage: testStatusMessage,
          isRedirect: testIsRedirect,
          redirects: testRedirects,
          headers: Headers.fromMap({
            HttpHeaders.contentLengthHeader: ['5134'],
          }),
        );

        expect(sut.contentLength, 5134);
      });

      test('returns -1 if header is not set', () {
        final sut = TResponseBody(
          data: testData,
          statusCode: testStatusCode,
          statusMessage: testStatusMessage,
          isRedirect: testIsRedirect,
          redirects: testRedirects,
          headers: testHeaders,
        );

        expect(sut.contentLength, -1);
      });
    });
  });
}
