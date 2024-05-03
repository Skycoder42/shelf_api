import 'dart:convert';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';

/// A generic wrapper around [Response] used for code generation.
class TResponse<T> extends Response {
  /// See [Response.new]
  TResponse(
    super.statusCode, {
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super(body: _toBody(body, encoding));

  /// See [Response.ok]
  TResponse.ok(
    T body, {
    super.headers,
    super.encoding,
    super.context,
  }) : super.ok(_toBody(body, encoding));

  /// See [Response.movedPermanently]
  TResponse.movedPermanently(
    super.location, {
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super.movedPermanently(body: _toBody(body, encoding));

  /// See [Response.found]
  TResponse.found(
    super.location, {
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super.found(body: _toBody(body, encoding));

  /// See [Response.seeOther]
  TResponse.seeOther(
    super.location, {
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super.seeOther(body: _toBody(body, encoding));

  /// See [Response.notModified]
  TResponse.notModified({
    super.headers,
    super.context,
  }) : super.notModified();

  /// See [Response.badRequest]
  TResponse.badRequest({
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super.badRequest(body: _toBody(body, encoding));

  /// See [Response.unauthorized]
  TResponse.unauthorized(
    Object? body, {
    super.headers,
    super.encoding,
    super.context,
  }) : super.unauthorized(_toBody(body, encoding));

  /// See [Response.forbidden]
  TResponse.forbidden(
    Object? body, {
    super.headers,
    super.encoding,
    super.context,
  }) : super.forbidden(_toBody(body, encoding));

  /// See [Response.notFound]
  TResponse.notFound(
    Object? body, {
    super.headers,
    super.encoding,
    super.context,
  }) : super.notFound(_toBody(body, encoding));

  /// See [Response.internalServerError]
  TResponse.internalServerError({
    Object? body,
    super.headers,
    super.encoding,
    super.context,
  }) : super.internalServerError(body: _toBody(body, encoding));

  @override
  Response change({
    Map<String, Object?>? headers,
    Map<String, Object?>? context,
    Object? body,
    Encoding? encoding,
  }) =>
      super.change(
        headers: headers,
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
}
