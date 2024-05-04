import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
// ignore: implementation_imports
import 'package:shelf/src/util.dart' show addHeader;

/// A generic wrapper around [Response] used for code generation.
class TResponse<T> extends Response {
  /// See [Response.new]
  TResponse(
    super.statusCode, {
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.ok]
  TResponse.ok(
    T body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.ok(
          _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.movedPermanently]
  TResponse.movedPermanently(
    super.location, {
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.movedPermanently(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.found]
  TResponse.found(
    super.location, {
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.found(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.seeOther]
  TResponse.seeOther(
    super.location, {
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.seeOther(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.notModified]
  TResponse.notModified({
    super.headers,
    super.context,
  }) : super.notModified();

  /// See [Response.badRequest]
  TResponse.badRequest({
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.badRequest(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.unauthorized]
  TResponse.unauthorized(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.unauthorized(
          _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.forbidden]
  TResponse.forbidden(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.forbidden(
          _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.notFound]
  TResponse.notFound(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.notFound(
          _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  /// See [Response.internalServerError]
  TResponse.internalServerError({
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.internalServerError(
          body: _toBody(body, encoding),
          headers: _addContentTypeHeader(headers, body),
        );

  @override
  Response change({
    Map<String, Object?>? headers,
    Map<String, Object?>? context,
    Object? body,
    Encoding? encoding,
  }) =>
      super.change(
        headers: {
          ...?headers,
          if (body != null) ...?_addContentTypeHeader(null, body),
        },
        context: context,
        body: _toBody(body, encoding),
      );

  static Object? _toBody(dynamic body, [Encoding? encoding]) => switch (body) {
        null => null,
        final String text => text,
        final Stream<String> stream =>
          stream.transform((encoding ?? utf8).encoder),
        final Uint8List bytes => bytes,
        final Stream<List<int>> stream => stream,
        final _ => json.encode(body),
      };

  static Map<String, Object>? _addContentTypeHeader(
    Map<String, Object>? headers,
    dynamic body,
  ) {
    final contentType = switch (body) {
      null => null,
      String() => ContentType.text,
      Stream<String>() => ContentType.text,
      Uint8List() => ContentType.binary,
      Stream<List<int>>() => ContentType.binary,
      final _ => ContentType.json,
    };

    if (contentType == null) {
      return headers;
    }

    return addHeader(
      headers,
      HttpHeaders.contentTypeHeader,
      contentType.toString(),
    );
  }
}
