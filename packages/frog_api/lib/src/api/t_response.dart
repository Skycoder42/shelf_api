import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';

/// A generic wrapper around [Response] used for code generation.
class TResponse<T> extends Response {
  /// Default constructor.
  factory TResponse({
    int? statusCode,
    required T body,
    Map<String, Object> headers = const <String, Object>{},
    Encoding? encoding,
    bool bufferOutput = true,
  }) =>
      switch (body) {
        final String text => TResponse._text(
            statusCode: statusCode ?? HttpStatus.ok,
            body: text,
            headers: headers,
            encoding: encoding,
          ),
        final Stream<String> stream => TResponse._stream(
            statusCode: statusCode ?? HttpStatus.ok,
            body: stream.transform((encoding ?? utf8).encoder),
            headers: headers,
            bufferOutput: bufferOutput,
          ),
        final Uint8List bytes => TResponse._bytes(
            statusCode: statusCode ?? HttpStatus.ok,
            body: bytes,
            headers: headers,
          ),
        final Stream<List<int>> stream => TResponse._stream(
            statusCode: statusCode ?? HttpStatus.ok,
            body: stream,
            headers: headers,
            bufferOutput: bufferOutput,
          ),
        final object => TResponse._json(
            statusCode: statusCode ?? HttpStatus.ok,
            body: object,
            headers: headers,
          ),
      };

  /// Moved permanently constructor.
  TResponse.movedPermanently({
    required super.location,
    super.body,
    super.headers,
    super.encoding,
  }) : super.movedPermanently();

  TResponse._json({
    super.statusCode,
    super.body,
    super.headers,
  }) : super.json();

  TResponse._text({
    super.statusCode,
    super.body,
    super.headers,
    super.encoding,
  }) : super();

  TResponse._stream({
    super.statusCode,
    super.body,
    super.headers,
    super.bufferOutput,
  }) : super.stream();

  TResponse._bytes({
    super.statusCode,
    super.body,
    super.headers,
  }) : super.bytes();
}
