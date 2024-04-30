import 'package:frog_api/src/util/map_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('FrogApiMapX', () {
    test('mapValue maps value of map', () {
      const testMap = {
        'a': 1,
        'b': 2,
      };

      final result = testMap.mapValue(
        expectAsync1(
          (v) => v * 2,
          count: 2,
        ),
      );

      expect(result, {'a': 2, 'b': 4});
    });
  });
}
