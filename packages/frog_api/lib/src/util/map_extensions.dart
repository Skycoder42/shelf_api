/// Utility extensions used by the code generator
extension FrogApiMapX<T> on Map<String, T> {
  /// Maps the value of this map via [map] to [T]
  Map<String, TNew> mapValue<TNew>(TNew Function(T) map) =>
      this.map((key, value) => MapEntry(key, map(value)));
}
