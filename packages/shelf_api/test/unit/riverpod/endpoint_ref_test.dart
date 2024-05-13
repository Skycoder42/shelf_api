import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf_api/src/riverpod/endpoint_ref.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<ShelfRequestRef>(),
  MockSpec<ProviderContainer>(),
  MockSpec<ProviderSubscription>(),
])
import 'endpoint_ref_test.mocks.dart';

// ignore: subtype_of_sealed_class, avoid_implementing_value_types
class _FakeProvider extends Fake implements ProviderBase, ProviderListenable {}

void main() {
  group('requestContext', () {
    final mockRef = MockShelfRequestRef();

    setUp(() {
      reset(mockRef);
    });

    test('throws state error by default', () {
      expect(
        () => shelfRequest(mockRef),
        throwsStateError,
      );
    });
  });

  group('EndpointRef', () {
    final testProvider = _FakeProvider();
    final mockProviderContainer = MockProviderContainer();

    late EndpointRef sut;

    setUp(() {
      reset(mockProviderContainer);

      sut = EndpointRef(mockProviderContainer);
    });

    test('exists calls container.exists and returns the result', () {
      when(mockProviderContainer.exists(any)).thenReturn(true);

      final result = sut.exists(testProvider);

      expect(result, isTrue);
      verify(mockProviderContainer.exists(testProvider)).called(1);
    });

    test('refresh calls container.refresh and returns the result', () {
      when(mockProviderContainer.refresh(any)).thenReturn(42);

      final result = sut.refresh(testProvider);

      expect(result, 42);
      verify(mockProviderContainer.refresh(testProvider)).called(1);
    });

    test('invalidate calls container.invalidate', () {
      sut.invalidate(testProvider);

      verify(mockProviderContainer.invalidate(testProvider)).called(1);
    });

    group('read', () {
      final mockProviderSubscription = MockProviderSubscription<int>();

      setUp(() {
        reset(mockProviderSubscription);

        when(mockProviderContainer.listen(any, any))
            .thenReturn(mockProviderSubscription);
      });

      test('calls container.listen and returns subscription value', () {
        when(mockProviderSubscription.read()).thenReturn(42);

        final result = sut.read(testProvider);

        expect(result, 42);

        verifyInOrder([
          mockProviderContainer.listen(testProvider, argThat(isNotNull)),
          mockProviderSubscription.read(),
        ]);
      });

      test('only listens to providers one', () {
        sut
          ..read(testProvider)
          ..read(testProvider);

        verifyInOrder([
          mockProviderContainer.listen(testProvider, argThat(isNotNull)),
          mockProviderSubscription.read(),
          mockProviderSubscription.read(),
        ]);
      });
    });

    test('dispose closes active subscriptions', () {
      final testProvider2 = _FakeProvider();
      final mockProviderSubscription1 = MockProviderSubscription<int>();
      final mockProviderSubscription2 = MockProviderSubscription<int>();

      when(mockProviderContainer.listen(testProvider, any))
          .thenReturn(mockProviderSubscription1);
      when(mockProviderContainer.listen(testProvider2, any))
          .thenReturn(mockProviderSubscription2);

      sut
        ..read(testProvider)
        ..read(testProvider2);

      clearInteractions(mockProviderSubscription1);
      clearInteractions(mockProviderSubscription2);

      sut.dispose();

      verify(mockProviderSubscription1.close()).called(1);
      verify(mockProviderSubscription2.close()).called(1);
    });
  });
}
