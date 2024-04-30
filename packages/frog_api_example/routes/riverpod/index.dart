import 'package:frog_api/frog_api.dart';
import 'package:frog_api_example/src/date_time_provider.dart';

Future<Response> onRequest(RequestContext context) async {
  final delay = int.parse(context.request.url.queryParameters['delay'] ?? '0');
  final mode = context.request.url.queryParameters['mode'];

  final timestamp = switch (mode) {
    'singleton' => context.ref.read(dateTimeSingletonProvider),
    'factory' => context.ref.read(dateTimeFactoryProvider),
    'requestSingleton' => context.ref.read(requestDateTimeSingletonProvider),
    'requestFactory' => context.ref.read(requestDateTimeFactoryProvider),
    _ => null,
  };

  await Future.delayed(Duration(milliseconds: delay));

  return Response(
    statusCode: timestamp == null ? HttpStatus.badRequest : HttpStatus.ok,
    body: timestamp?.toIso8601String(),
  );
}
