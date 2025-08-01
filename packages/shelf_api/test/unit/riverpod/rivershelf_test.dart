// ignore_for_file: discarded_futures

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_api/src/api/http_method.dart';
import 'package:shelf_api/src/riverpod/endpoint_ref.dart';
import 'package:shelf_api/src/riverpod/rivershelf.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<Request>()])
import 'rivershelf_test.mocks.dart';

class FakeResponse extends Fake implements Response {}

class FakeEndpointRef extends Fake implements EndpointRef {
  @override
  final ProviderContainer container;

  FakeEndpointRef(this.container);
}

void main() {
  group('RivershelfMiddleware', () {
    final mockRequest = MockRequest();

    late ProviderContainer testProviderContainer;
    late Middleware sut;

    setUp(() {
      reset(mockRequest);
      testProviderContainer = ProviderContainer();

      sut = rivershelf(parent: testProviderContainer);
    });

    tearDown(() {
      testProviderContainer.dispose();
    });

    test('creates pipeline with given handler', () {
      final testResponse = FakeResponse();
      final newHandler = sut(
        expectAsync1((request) {
          expect(request, isNot(same(mockRequest)));
          return testResponse;
        }),
      );

      expect(newHandler(mockRequest), completion(testResponse));
    });

    test('creates pipeline with existing container', () {
      sut = rivershelfContainer(testProviderContainer);

      final testResponse = FakeResponse();
      final newHandler = sut(
        expectAsync1((request) {
          expect(request, isNot(same(mockRequest)));
          return testResponse;
        }),
      );

      expect(newHandler(mockRequest), completion(testResponse));
    });

    test('registers endpoint ref on context', () {
      final testResponse = FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      expect(context, containsPair(rivershelfRefKey, isA<EndpointRef>()));
    });

    test('uses scoped provider container with context override', () {
      final testResponse = FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      expect(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      final container = (context[rivershelfRefKey]! as EndpointRef).container;
      expect(container, isNot(testProviderContainer));
      expect(container.depth, 2);

      expect(
        () => testProviderContainer.read(shelfRequestProvider),
        throwsStateError,
      );
      final providedContext = container.read(shelfRequestProvider);
      expect(providedContext, same(mockRequest));
    });

    test('disposes scoped container', () async {
      final testResponse = FakeResponse();
      final newHandler = sut(expectAsync1((context) => testResponse));

      await expectLater(newHandler(mockRequest), completes);

      final VerificationResult(captured: [Map<String, Object?> context]) =
          verify(mockRequest.change(context: captureAnyNamed('context')));

      final container = (context[rivershelfRefKey]! as EndpointRef).container;
      expect(
        () => container.read(shelfRequestProvider),
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

  group('RequestRivershelfExtension', () {
    final mockRequest = MockRequest();

    late ProviderContainer testProviderContainer;

    setUp(() {
      reset(mockRequest);
      testProviderContainer = ProviderContainer(
        overrides: [shelfRequestProvider.overrideWithValue(MockRequest())],
      );
    });

    tearDown(() {
      testProviderContainer.dispose();
    });

    test('ref returns EndpointRef of request context and updates override', () {
      final testRef = FakeEndpointRef(testProviderContainer);
      final request = Request(
        HttpMethod.get,
        Uri.http('localhost', '/'),
        context: {rivershelfRefKey: testRef},
      );

      expect(request.ref, same(testRef));
      expect(testProviderContainer.read(shelfRequestProvider), same(request));
    });

    test('ref only updates override once', () {
      final testRef = FakeEndpointRef(testProviderContainer);
      final request = Request(
        HttpMethod.get,
        Uri.http('localhost', '/'),
        context: {rivershelfRefKey: testRef},
      );

      expect(request.ref, same(testRef));

      testProviderContainer.updateOverrides([
        shelfRequestProvider.overrideWithValue(mockRequest),
      ]);

      expect(request.ref, same(testRef));
      expect(
        testProviderContainer.read(shelfRequestProvider),
        same(mockRequest),
      );
    });

    test('asserts if not ref is available', () {
      final request = Request(HttpMethod.get, Uri.http('localhost', '/'));

      expect(() => request.ref, throwsA(isA<AssertionError>()));
    });
  });
}
