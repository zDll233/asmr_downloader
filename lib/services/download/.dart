Future<Return> rangeDownload({
    required String url,
    required File targetFile,
    bool ignoreTargetFilePreviousContent = false,
    int bufferSize = 1024 * 1024, // 1 Megabyte
    StreamController<double>? progressStreamController,
  }) async {
    // [01]: Getting http head info
    final headInfo = await url.getHttpHeadInfo(this);

    // [02]: Error checking
    {
      // (01)
      if (headInfo == null) {
        return Return.error('Failed to retrieve remote resource HEAD info');
      }

      // (02)
      if (headInfo.contentLength == null) {
        return Return.error(
            'Remote resource HEAD info does not contain Content Length');
      }

      // (03)
      if (headInfo.rangeFeatureEnabled == null) {
        return Return.error(
            'Remote resource HEAD info does not Range Feature Enabled');
      }

      // (04)
      if (!headInfo.rangeFeatureEnabled!) {
        return Return.error('Remote resource does not support Range Feature');
      }

      if (!ignoreTargetFilePreviousContent && targetFile.existsSync()) {
        final length = targetFile.lengthSync();

        // [A]: Seems to be yet full downloaded
        if (length == headInfo.contentLength!) {
          return success;
        }

        // [B]: Seems that target file is corrupted
        if (length > headInfo.contentLength!) {
          return Return.error('Target file seems to be corrupted');
        }
      }
    }

    // [03]: Getting target file length
    final targetFileLength =
        !ignoreTargetFilePreviousContent && targetFile.existsSync()
            ? targetFile.lengthSync()
            : null;

    // [04]: Opening file to write
    final sink = targetFile.openWrite(
      mode: ignoreTargetFilePreviousContent
          ? FileMode.writeOnly
          : FileMode.writeOnlyAppend,
    );

    // [05]: Calculating initial range values
    int rangeStart = targetFileLength ?? 0;
    int rangeEnd = min(
      rangeStart + bufferSize - 1,
      headInfo.contentLength! - 1,
    );

    // [06]: Streaming base progress
    double progress = -1;
    if (progressStreamController != null) {
      progress =
          ((rangeStart / headInfo.contentLength!) * 100).withFractionDigits();

      progressStreamController.add(progress);
    }

    // [07]: Iterating until full content is downloaded
    while (true) {
      // Sending response
      final response = await get(
        url,
        onReceiveProgress: (count, total) {
          // Streaming progress update
          if (progressStreamController != null) {
            final newProgress =
                (((rangeStart + count) / headInfo.contentLength!) * 100)
                    .withFractionDigits();
            if (newProgress != progress) {
              progress = newProgress;
              progressStreamController.add(progress);
            }
          }
        },
        options: Options(
          headers: {
            'range': 'bytes=$rangeStart-$rangeEnd',
          },
          responseType: ResponseType.bytes,
        ),
      );

      // Response failed
      if (!response.successPartialContent) {
        return Return.error(
          'Response failed with status code: ${response.statusCode}. Expected success partial content (206)',
        );
      }

      // Data
      final Uint8List data = response.data;

      // Writing data
      sink.add(data);

      // Checking finished
      if (rangeEnd == headInfo.contentLength! - 1) {
        break;
      }

      // Recalculating range values
      rangeStart = rangeEnd + 1;
      rangeEnd = min(
        rangeStart + bufferSize - 1,
        headInfo.contentLength! - 1,
      );
    }

    // [08]: Flushing
    await sink.flush();

    // [09]: Closing
    await sink.close();

    return success;
  }

/// Extension method on String
Future<HttpHeadInfo?> getHttpHeadInfo([Dio? dio]) async {
    try {
      // [01]: Sending response
      final response = await (dio ?? Dio()).head(this);

      if (!response.success) {
        return null;
      }

      // [02]: Parsing content length
      int? contentLength;
      {
        final contentLengthHeaderValue = response.headers.map['content-length'];
        if (contentLengthHeaderValue != null &&
            contentLengthHeaderValue.isNotEmpty) {
          contentLength = int.tryParse(contentLengthHeaderValue.first);
        }
      }

      // [03]: Parsing range feature enabled
      bool? rangeFeatureEnabled;
      {
        final rangeFeatureEnabledValue = response.headers.map['accept-ranges'];
        if (rangeFeatureEnabledValue != null &&
            rangeFeatureEnabledValue.isNotEmpty) {
          final acceptRanges =
              rangeFeatureEnabledValue.first.trim().toLowerCase();
          rangeFeatureEnabled = acceptRanges == 'bytes';
        }
      }

      return HttpHeadInfo(
        contentLength: contentLength,
        rangeFeatureEnabled: rangeFeatureEnabled,
      );
    } catch (e) {
      return null;
    }
  }

/// Utility class
class HttpHeadInfo {
  // Data

  //#region
  final int? contentLength;
  final bool? rangeFeatureEnabled;
  //#endregion

  /// Constructor.
  HttpHeadInfo({
    required this.contentLength,
    required this.rangeFeatureEnabled,
  });
}
