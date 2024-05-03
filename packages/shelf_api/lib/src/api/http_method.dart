/// HTTP request method.
abstract base class HttpMethod {
  HttpMethod._();

  /// CONNECT
  static const connect = 'CONNECT';

  /// DELETE
  static const delete = 'DELETE';

  /// GET
  static const get = 'GET';

  /// HEAD
  static const head = 'HEAD';

  /// OPTIONS
  static const options = 'OPTIONS';

  /// PATCH
  static const patch = 'PATCH';

  /// POST
  static const post = 'POST';

  /// PUT
  static const put = 'PUT';

  /// TRACE
  static const trace = 'TRACE';

  /// All known http methods.
  static const values = [
    connect,
    delete,
    get,
    head,
    options,
    patch,
    post,
    put,
    trace,
  ];
}
