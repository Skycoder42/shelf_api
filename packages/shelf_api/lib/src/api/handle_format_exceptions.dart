import 'package:shelf/shelf.dart';

// TODO logging?

/// A key to get the original [FormatException] from [Request.context].
///
/// Can only be used if the response was created by the
/// [handleFormatExceptions] middleware.
const handleFormatExceptionsOriginalExceptionKey =
    'handleFormatExceptions.originalException';

/// A key to get the original [StackTrace] from [Request.context].
///
/// Can only be used if the response was created by the
/// [handleFormatExceptions] middleware.
const handleFormatExceptionsOriginalStackTraceKey =
    'handleFormatExceptions.originalStackTrace';

/// A middleware that handles [FormatException]s
///
/// Automatically returns a [Response.badRequest] with the
/// [FormatException.message] as response body.
///
/// The original [FormatException] and [StackTrace] will also be stored in
/// the [Response.context] in case further logging should take place. The keys
/// are: [handleFormatExceptionsOriginalExceptionKey] and
/// [handleFormatExceptionsOriginalStackTraceKey]
Middleware handleFormatExceptions() => _HandleFormatExceptionsMiddleware().call;

class _HandleFormatExceptionsMiddleware {
  Handler call(Handler next) => (request) async {
        try {
          return await next(request);
        } on FormatException catch (e, s) {
          return Response.badRequest(
            body: e.message,
            context: {
              handleFormatExceptionsOriginalExceptionKey: e,
              handleFormatExceptionsOriginalStackTraceKey: s,
            },
          );
        }
      };
}
