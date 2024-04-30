extension FrogApiMapX<T> on Map<String, T> {
  Map<String, TNew> mapValue<TNew>(TNew Function(T) map) =>
      this.map((key, value) => MapEntry(key, map(value)));
}
