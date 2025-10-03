import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf_api/src/riverpod/endpoint_ref.dart';
import 'package:test/test.dart';

void main() {
  group('requestContext', () {
    late ProviderContainer testContainer;

    setUp(() {
      testContainer = ProviderContainer.test();
    });

    test('throws state error by default', () {
      expect(
        () => testContainer.read(shelfRequestProvider),
        throwsA(
          isA<ProviderException>().having(
            (m) => m.exception,
            'exception',
            isStateError,
          ),
        ),
      );
    });
  });

  group('EndpointRef', () {
    late ProviderContainer testContainer;
    late var callCounter = 0;
    final testProvider = Provider((ref) => ++callCounter);

    late EndpointRef sut;

    setUp(() {
      callCounter = 0;
      testContainer = ProviderContainer.test();
      sut = EndpointRef(testContainer);
    });

    test('exists calls container.exists and returns the result', () {
      expect(sut.exists(testProvider), isFalse);
      sut.read(testProvider);
      expect(sut.exists(testProvider), isTrue);
    });

    test('refresh calls container.refresh and returns the result', () {
      final original = sut.read(testProvider);
      expect(original, 1);

      final result = sut.refresh(testProvider);
      expect(result, 2);
    });

    test('invalidate calls container.invalidate', () {
      final original = sut.read(testProvider);
      expect(original, 1);

      sut.invalidate(testProvider);

      final result = sut.read(testProvider);
      expect(result, 2);
    });

    test(
      'read calls container.listen and returns subscription value',
      () async {
        final r1 = sut.read(testProvider);
        expect(r1, 1);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final r2 = sut.read(testProvider);
        expect(r2, 1);
      },
    );
  });
}
