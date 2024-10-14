import 'dart:io';
import 'package:asmr_downloader/utils/download.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:path/path.dart' as p;

Future<void> voiceWorkDirAndCover(
  String rj,
  String title,
  List<String> cvLs,
  String coverUrl,
  String downloadPath,
) async {
  // cv1&cv2&...&cvn-title
  final dirName = '${cvLs.join('&')}-$title';
  final rjDirPath = p.join(
    downloadPath,
    dirName,
    rj,
  );
  Log.i('Creating directory $rjDirPath');
  Directory(rjDirPath).createSync(recursive: true);

  // 下载cover
  String coverPath = p.join(rjDirPath, 'cover.jpg');
  try {
    await dioDownload(coverUrl, coverPath);
  } catch (e) {
    Log.error('Download cover failed: $e');
  }
}
