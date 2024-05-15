import 'package:dio/dio.dart';

/// A wrapper around a HTTP response for typed responses.
class TResponseBody<T> {
  /// The decoded response body.
  final T data;

  /// HTTP status code.
  final int statusCode;

  /// Returns the reason phrase corresponds to the status code.
  final String? statusMessage;

  /// Whether this response is a redirect.
  final bool isRedirect;

  /// Stores redirections during the request.
  final List<RedirectRecord>? redirects;

  /// The response headers.
  final Headers headers;

  /// Default constructor.
  TResponseBody({
    required this.data,
    required this.statusCode,
    required this.statusMessage,
    required this.isRedirect,
    required this.redirects,
    required this.headers,
  });

  /// Creates a TResponseBody from a [response] and the already decoded [data].
  TResponseBody.fromResponse(Response response, this.data)
      : statusCode = response.statusCode ?? 200,
        statusMessage = response.statusMessage,
        isRedirect = response.isRedirect,
        redirects = response.redirects,
        headers = response.headers;

  /// Creates a TResponseBody from a [responseBody] and the already decoded
  /// [data].
  TResponseBody.fromResponseBody(ResponseBody responseBody, this.data)
      : statusCode = responseBody.statusCode,
        statusMessage = responseBody.statusMessage,
        isRedirect = responseBody.isRedirect,
        redirects = responseBody.redirects,
        headers = Headers.fromMap(responseBody.headers);

  /// Content length of the response or -1 if not specified
  int get contentLength =>
      int.parse(headers.value(Headers.contentLengthHeader) ?? '-1');
}
