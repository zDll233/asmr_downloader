import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/utils/download.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:path/path.dart' as p;

Future<void> downloadTrackItem(
    TrackItem trackItem, String targetDirPath) async {
  if (trackItem is Folder) {
    final dirPath = p.join(targetDirPath, trackItem.title);
    for (final child in trackItem.children) {
      downloadTrackItem(child, dirPath);
    }
  } else if (trackItem is FileAsset) {
    final targetPath = p.join(
        targetDirPath, trackItem.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), ''));
    if (trackItem.selected) {
      try {
        await dioDownload(trackItem.mediaDownloadUrl, targetPath);
      } catch (e) {
        Log.error('Download ${trackItem.title} failed: $e');
      }
    }
  }
}
