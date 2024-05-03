/// HTTP request method.
enum HttpMethod {
  /// CONNECT
  connect('CONNECT'),

  /// DELETE
  delete('DELETE'),

  /// GET
  get('GET'),

  /// HEAD
  head('HEAD'),

  /// OPTIONS
  options('OPTIONS'),

  /// PATCH
  patch('PATCH'),

  /// POST
  post('POST'),

  /// PUT
  put('PUT'),

  /// TRACE
  trace('TRACE');

  /// The HTTP method verb
  final String verb;

  const HttpMethod(this.verb);
}
