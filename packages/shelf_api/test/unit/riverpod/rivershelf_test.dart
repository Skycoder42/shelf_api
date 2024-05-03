// ignore_for_file: discarded_futures

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/riverpod/endpoint_ref.dart';
import 'package:shelf_api/src/riverpod/rivershelf.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<Request>(),
])
import 'rivershelf_test.mocks.dart';

class _FakeResponse extends Fake implements Response {}

void main() {
  group('RivershelfMiddleware', () {
    final mockRequest = MockRequest();

    late ProviderContainer testProviderContainer;
    late RivershelfMiddleware sut;

    setUp(() {
      reset(mockRequest);
      testProviderContainer = ProviderContainer();

      sut = RivershelfMiddleware(parent: testProviderContainer);
    });

    tearDown(() {
      testProviderContainer.dispose();
    });

    test('creates pipeline with given handler', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(
        expectAsync1((request) {
          expect(request, isNot(same(mockRequest)));
          return testResponse;
        }),
      );

      expect(newHandler(mockRequest), completion(testResponse));
    });

    test('registers endpoint ref on context', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      expect(
        context,
        containsPair(RivershelfMiddleware.refKey, isA<EndpointRef>()),
      );
    });

    test('uses scoped provider container with context override', () {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      final container =
          (context[RivershelfMiddleware.refKey]! as EndpointRef).container;
      expect(container, isNot(testProviderContainer));
      expect(container.depth, 2);

      expect(
        () => testProviderContainer.read(requestProvider),
        throwsStateError,
      );
      final providedContext = container.read(requestProvider);
      expect(providedContext, same(mockRequest));
    });

    test('disposes scoped container', () async {
      final testResponse = _FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      await expectLater(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      final container =
          (context[RivershelfMiddleware.refKey]! as EndpointRef).container;
      expect(
        () => container.read(requestProvider),
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
