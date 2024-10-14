import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';

Future<Response<dynamic>> dioDownload(
  String urlPath,
  dynamic savePath, {
  int maxTry = 3,
  void Function(int, int)? onReceiveProgress,
}) async {
  Response? response;
  int tryCount = 0;
  while (tryCount < maxTry && response == null) {
    try {
      tryCount++;
      Log.i('Current try:$tryCount\nDownloading $urlPath');
      response = await Dio().download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      Log.i('Downloaded $urlPath into $savePath');
    } catch (e) {
      Log.warning('Currrent try:$tryCount\nDownload failed: $e');
    }
  }
  if (response == null) {
    Log.error('Download failed after $maxTry tries');
    return Future.error('Download failed after $maxTry tries');
  } else {
    return response;
  }
}
