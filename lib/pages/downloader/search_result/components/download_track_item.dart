import 'dart:io';
import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

Future<void> downloadTrackItem(
    WidgetRef ref, TrackItem trackItem, String targetDirPath) async {
  final api = ref.read(asmrApiProvider);
  if (trackItem is Folder) {
    final dirPath = p.join(targetDirPath, trackItem.title);
    Log.info('Creating directory $dirPath');
    Directory(dirPath).createSync(recursive: true);
    for (final child in trackItem.children) {
      downloadTrackItem(ref, child, dirPath);
    }
  } else if (trackItem is FileAsset) {
    final targetPath = p.join(targetDirPath, trackItem.title);
    if (trackItem.selected) {
      Log.info('Downloading ${trackItem.title} to $targetPath');
      await api.download(trackItem.mediaDownloadUrl, targetPath);
      Log.info('Download ${trackItem.title} finished');
    } else {
      Log.info('Skipping ${trackItem.title}');
    }
  }
}
