extension DartFromStreamX on Stream<List<int>> {
  Future<List<int>> collect() =>
      fold([], (previous, element) => previous..addAll(element));
}
