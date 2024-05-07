import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

/// A key to get the original [FormatException] from [Request.context].
///
/// Can only be used if the response was created by the
/// [formatExceptionHandler] middleware.
const formatExceptionOriginalExceptionKey =
    'formatExceptionHandler.originalException';

/// A key to get the original [StackTrace] from [Request.context].
///
/// Can only be used if the response was created by the
/// [formatExceptionHandler] middleware.
const formatExceptionOriginalStackTraceKey =
    'formatExceptionHandler.originalStackTrace';

/// A middleware that handles [FormatException]s
///
/// Automatically returns a [Response.badRequest] with the
/// [FormatException.message] as response body.
///
/// The original [FormatException] and [StackTrace] will also be stored in
/// the [Response.context] in case further logging should take place. The keys
/// are: [formatExceptionOriginalExceptionKey] and
/// [formatExceptionOriginalStackTraceKey]
Middleware formatExceptionHandler() => FormatExceptionHandlerMiddleware().call;

@internal
@visibleForTesting
class FormatExceptionHandlerMiddleware {
  Handler call(Handler next) => (request) async {
        try {
          return await next(request);
        } on FormatException catch (e, s) {
          return Response.badRequest(
            body: e.message,
            context: {
              formatExceptionOriginalExceptionKey: e,
              formatExceptionOriginalStackTraceKey: s,
            },
          );
        }
      };
}
