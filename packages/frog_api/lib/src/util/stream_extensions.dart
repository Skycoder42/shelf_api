import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';

/// Utility extensions used by the code generator
extension FrogApiStreamX on Stream<List<int>> {
  /// Collects the data from the stream into a single [Uint8List]
  Future<Uint8List> collect([Request? request]) async {
    if (request != null) {
      final rawContentLength = request.headers[HttpHeaders.contentLengthHeader];
      final contentLength =
          rawContentLength != null ? int.tryParse(rawContentLength) : null;

      if (contentLength != null) {
        var offset = 0;
        final bytes = Uint8List(contentLength);
        await for (final block in this) {
          if (offset + block.length > contentLength) {
            throw HttpException(
              'Received more data than declared by '
              'the content-length header of $contentLength!',
              uri: request.uri,
            );
          }

          bytes.setRange(offset, block.length, block);
          offset += block.length;
        }
      }
    }

    return Uint8List.fromList(
      await fold([], (previous, element) => previous..addAll(element)),
    );
  }
}
