import 'package:shelf_api/shelf_api.dart';

import 'date_time_provider.dart';

Future<Response> riverpodRequestHandler(Request request) async {
  final delay = int.parse(request.url.queryParameters['delay'] ?? '0');
  final mode = request.url.queryParameters['mode'];

  final timestamp = switch (mode) {
    'singleton' => request.ref.read(dateTimeSingletonProvider),
    'factory' => request.ref.read(dateTimeFactoryProvider),
    'requestSingleton' => request.ref.read(requestDateTimeSingletonProvider),
    'requestFactory' => request.ref.read(requestDateTimeFactoryProvider),
    _ => null,
  };

  await Future.delayed(Duration(milliseconds: delay));

  return Response(
    timestamp == null ? HttpStatus.badRequest : HttpStatus.ok,
    body: timestamp?.toIso8601String(),
  );
}
