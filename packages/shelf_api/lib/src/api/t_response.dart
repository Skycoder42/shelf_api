import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:shelf/shelf.dart';
// ignore: implementation_imports for helper utility
import 'package:shelf/src/util.dart' show addHeader;

import 'content_types.dart';

/// A generic wrapper around [Response] used for code generation.
class TResponse<T> extends Response {
  /// See [Response.new]
  new(
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
  new ok(T body, {Map<String, Object>? headers, super.encoding, super.context})
    : super.ok(
        _toBody(body, encoding),
        headers: _addContentTypeHeader(headers, body),
      );

  /// See [Response.movedPermanently]
  new movedPermanently(
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
  new found(
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
  new seeOther(
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
  new notModified({super.headers, super.context}) : super.notModified();

  /// See [Response.badRequest]
  new badRequest({
    Object? body,
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.badRequest(
         body: _toBody(body, encoding),
         headers: _addContentTypeHeader(headers, body),
       );

  /// See [Response.unauthorized]
  new unauthorized(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.unauthorized(
         _toBody(body, encoding),
         headers: _addContentTypeHeader(headers, body),
       );

  /// See [Response.forbidden]
  new forbidden(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.forbidden(
         _toBody(body, encoding),
         headers: _addContentTypeHeader(headers, body),
       );

  /// See [Response.notFound]
  new notFound(
    Object? body, {
    Map<String, Object>? headers,
    super.encoding,
    super.context,
  }) : super.notFound(
         _toBody(body, encoding),
         headers: _addContentTypeHeader(headers, body),
       );

  /// See [Response.internalServerError]
  new internalServerError({
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
  }) => super.change(
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
    final Stream<String> stream => stream.transform((encoding ?? utf8).encoder),
    final Uint8List bytes => bytes,
    final Stream<List<int>> stream => stream,
    final _ => json.encode(body),
  };

  static Map<String, Object>? _addContentTypeHeader(
    Map<String, Object>? headers,
    dynamic body,
  ) {
    const contentTypeHeader = 'Content-Type';
    if (headers?.keys.any((h) => equalsIgnoreAsciiCase(h, contentTypeHeader)) ??
        false) {
      return headers;
    }

    final contentType = switch (body) {
      null => null,
      String() => ContentTypes.text,
      Stream<String>() => ContentTypes.text,
      Uint8List() => ContentTypes.binary,
      Stream<List<int>>() => ContentTypes.binary,
      final _ => ContentTypes.json,
    };

    if (contentType == null) {
      return headers;
    }

    return addHeader(headers, contentTypeHeader, contentType);
  }
}
