import 'package:asmr_downloader/models/track_item.dart';
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

final rootFolderProvider = StateProvider<Folder>((ref) {
  return Folder(id: '', title: '');
});

final dlStatusProvider = StateProvider((ref) => DownloadStatus.notStarted);

final processProvider = StateProvider<double>((ref) => 0);

final currentFileNameProvider = StateProvider<String>((ref) => '');

final currentDlProvider = StateProvider<int>((ref) => 0);
final totalTaskCntProvider = StateProvider<int>((ref) => 0);
