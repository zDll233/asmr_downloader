import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/services/asmr_repo/parse_tracks.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

final downloadPathProvider = StateProvider<String>((ref) => '');

final targetDirPathProvider = Provider<String>((ref) {
  final downloadPath = ref.watch(downloadPathProvider);
  final title = ref.watch(titleProvider);
  final cvLs = ref.watch(cvLsProvider);

  // cv1&cv2&...&cvn-title
  final dirName =
      '${cvLs.join('&')}-$title'.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  final targetDirPath = p.join(downloadPath, dirName);
  return targetDirPath;
});

final rjProvider = StateProvider<String>((ref) => '');

final rootFolderProvider = StateProvider<Folder?>((ref) {
  final tracks = ref.watch(rawTracksProvider);
  final rj = ref.read(rjProvider);
  return tracks.maybeWhen(
      data: (data) {
        if (data == null) {
          return null;
        }
        return Folder(id: rj, title: rj)..children = getTrackItems(data);
      },
      orElse: () => null);
});

final dlStatusProvider = StateProvider((ref) => DownloadStatus.notStarted);

final processProvider = StateProvider<double>((ref) => 0);

final currentFileNameProvider = StateProvider<String>((ref) => '');

final currentDlNoProvider = StateProvider<int>((ref) => 0);
final totalTaskCntProvider = StateProvider<int>((ref) => 0);
