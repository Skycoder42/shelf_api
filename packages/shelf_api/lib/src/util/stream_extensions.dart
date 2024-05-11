import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:shelf/shelf.dart';

/// Utility extensions used by the code generator
extension ShelfApiStreamX<T> on Stream<T> {
  /// Registers a callback to be invoked once the stream is done
  Stream<T> onFinished(FutureOr<void> Function() callback) {
    var finished = false;
    FutureOr<void> finishedCallback() {
      if (finished) {
        return null;
      }
      finished = true;
      // ignore: discarded_futures
      return callback();
    }

    return cast<T>().transform(
      DoStreamTransformer<T>(
        onCancel: finishedCallback,
        onDone: finishedCallback,
      ),
    );
  }
}

/// Utility extensions used by the code generator
extension ShelfApiByteStreamX on Stream<List<int>> {
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
