import 'dart:typed_data';

extension FrogApiStreamX on Stream<List<int>> {
  Future<Uint8List> collect() async => Uint8List.fromList(
        await fold([], (previous, element) => previous..addAll(element)),
      );
}
