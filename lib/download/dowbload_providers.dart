import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

final downloadPathProvider = StateProvider<String>((ref) => '');

final targetDirPathProvider = Provider<String>((ref) {
  final downloadPath = ref.watch(downloadPathProvider);
  final title = ref.watch(titleProvider);
  final cvLs = ref.watch(cvLsProvider);

  // cv1&cv2&...&cvn-title
  final dirName = '${cvLs.join('&')}-$title';
  final targetDirPath = p.join(downloadPath, dirName);
  return targetDirPath;
});

final rjProvider = StateProvider<String>((ref) => '');

final rootFolderProvider = StateProvider<Folder>((ref) {
  return Folder(title: '');
});
