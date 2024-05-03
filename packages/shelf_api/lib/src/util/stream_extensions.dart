import 'dart:io';
import 'dart:typed_data';

import '../../shelf_api.dart';

/// Utility extensions used by the code generator
extension ShelfApiStreamX on Stream<List<int>> {
  /// Collects the data from the stream into a single [Uint8List]
  Future<Uint8List> collect([Request? request]) async {
    if (request != null) {
      if (request.contentLength case final int contentLength) {
        var offset = 0;
        final bytes = Uint8List(contentLength);
        await for (final block in this) {
          if (offset + block.length > contentLength) {
            throw HttpException(
              'Received more data than declared by '
              'the content-length header of $contentLength!',
              uri: request.requestedUri,
            );
          }

          bytes.setAll(offset, block);
          offset += block.length;
        }

        return bytes;
      }
    }

    return Uint8List.fromList(
      await fold([], (previous, element) => previous..addAll(element)),
    );
  }
}
