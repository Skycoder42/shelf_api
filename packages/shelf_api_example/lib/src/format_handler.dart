import 'package:shelf/shelf.dart';

Future<Response> formatHandler(Request request) async =>
    throw FormatException(await request.readAsString());
