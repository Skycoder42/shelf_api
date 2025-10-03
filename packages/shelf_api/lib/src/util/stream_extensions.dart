import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:shelf/shelf.dart';

/// Utility extensions used by the code generator
extension ShelfApiStreamX<T> on Stream<T> {
  /// Registers a callback to be invoked once the stream is done
  Stream<T> onFinished(FutureOr<void> Function() callback) {
    var finished = false;
    Future<void> finishedCallback() async {
      if (finished) {
        return;
      }
      finished = true;
      return await callback();
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
  ///
  /// If [request] is specified, the method will try to read the
  /// `Content-Length` header and pre-allocate memory for a more efficient
  /// conversion.
  Future<Uint8List> collect([Request? request]) async {
    if (request != null) {
      if (request.contentLength case final int contentLength) {
        var offset = 0;
        final bytes = Uint8List(contentLength);
        await for (final block in this) {
          if (offset + block.length > contentLength) {
            bytes.setRange(offset, contentLength, block);
            break;
          } else {
            bytes.setAll(offset, block);
            offset += block.length;
          }
        }

        return bytes;
      }
    }

    return Uint8List.fromList(
      await fold([], (previous, element) => previous..addAll(element)),
    );
  }
}
