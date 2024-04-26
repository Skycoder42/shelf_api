// ignore_for_file: discarded_futures

import 'package:dart_frog/dart_frog.dart';
import 'package:frog_api/src/riverpod/endpoint_ref.dart';
import 'package:frog_api/src/riverpod/riverfrog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<RequestContext>(),
  MockSpec<Request>(),
])
import 'riverfrog_test.mocks.dart';

class _FakeResponse extends Fake implements Response {}

void main() {
  group('RiverfrogMiddleware', () {
    final mockRequestContext = MockRequestContext();
    final mockRequest = MockRequest();

    late ProviderContainer testProviderContainer;
    late RiverfrogMiddleware sut;

    setUp(() {
      reset(mockRequestContext);
      reset(mockRequest);
      testProviderContainer = ProviderContainer();

      when(mockRequestContext.request).thenReturn(mockRequest);

      sut = RiverfrogMiddleware(testProviderContainer);
    });

    tearDown(() {
      testProviderContainer.dispose();
    });

    test('creates pipeline with given handler', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(
        expectAsync1((context) {
          expect(context, isNot(same(mockRequestContext)));
          return testResponse;
        }),
      );

      expect(newHandler(mockRequestContext), completion(testResponse));
    });

    test('registers endpoint ref on context', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequestContext), completes);

      final VerificationResult(
        captured: [
          EndpointRef Function() factory,
        ]
      ) = verify(mockRequestContext.provide<EndpointRef>(captureAny));

      expect(factory(), isA<EndpointRef>());
    });

    test('uses scoped provider container with context override', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequestContext), completes);

      final VerificationResult(
        captured: [
          EndpointRef Function() factory,
        ]
      ) = verify(mockRequestContext.provide<EndpointRef>(captureAny));

      final container = factory().container;
      expect(container, isNot(testProviderContainer));
      expect(container.depth, 1);

      expect(
        () => testProviderContainer.read(requestContextProvider),
        throwsStateError,
      );
      final providedContext = container.read(requestContextProvider);
      expect(providedContext, same(mockRequestContext));
    });

    test('disposes scoped container', () async {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      await expectLater(newHandler(mockRequestContext), completes);

      final VerificationResult(
        captured: [
          EndpointRef Function() factory,
        ]
      ) = verify(mockRequestContext.provide<EndpointRef>(captureAny));

      expect(
        () => factory().container.read(requestContextProvider),
        throwsA(
          isStateError.having(
            (m) => m.message,
            'message',
            contains('disposed'),
          ),
        ),
      );
    });
  });
}
