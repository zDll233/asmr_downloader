import 'dart:io';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

Future<void> voiceWorkDirAndCover(
  WidgetRef ref,
  String title,
  List<String> cvLs,
  String coverUrl,
  String downloadPath,
) async {
  final api = ref.read(asmrApiProvider);

  // cv1&cv2&...&cvn-title
  final dirName = '${cvLs.join('&')}-$title';
  final rjDirPath = p.join(
    downloadPath,
    dirName,
    ref.read(rjProvider),
  );
  Log.info('Creating directory $rjDirPath');
  Directory(rjDirPath).createSync(recursive: true);

  // 下载cover
  String coverPath = p.join(rjDirPath, 'cover.jpg');
  // await Dio().download(coverUrl, coverPath);
  await api.download(coverUrl, coverPath);
  Log.info('Download cover to $coverPath successfully');
}
