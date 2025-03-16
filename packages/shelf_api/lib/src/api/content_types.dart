/// Constants for the default content types typically used by APIs
abstract base class ContentTypes {
  ContentTypes._();

  /// Content type for plain text.
  static const text = 'text/plain';

  /// Content type for binary data.
  static const binary = 'application/octet-stream';

  /// Content type for JSON.
  static const json = 'application/json';

  /// All default content types.
  static const values = [text, binary, json];
}
