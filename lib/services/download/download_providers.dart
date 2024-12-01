import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/services/asmr_repo/parse_tracks.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/utils/legal_windows_name.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

final targetDirPathProvider = Provider<String>((ref) {
  final downloadPath = ref.watch(downloadPathProvider);
  final title = ref.watch(titleProvider);
  final cvLs = ref.watch(cvLsProvider);

  // cv1&cv2&...&cvn-title
  final dirName = getLegalWindowsName('${cvLs.join('&')}-$title');
  return p.join(downloadPath, dirName);
});

final searchTextProvider = StateProvider<String?>((ref) => null);

final idSearchResultProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final searchText = ref.watch(searchTextProvider);
  if (searchText == null || searchText.startsWith('RJ')) {
    return null;
  }

  Log.info('Search $searchText');
  final api = ref.watch(asmrApiProvider);
  return api.search(content: searchText);
});

final idProvider = Provider<String?>((ref) {
  final searchText = ref.watch(searchTextProvider);
  if (searchText == null) {
    return null;
  }
  if (searchText.startsWith('RJ')) {
    return searchText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  final idSearchResult = ref.watch(idSearchResultProvider);
  return idSearchResult.maybeWhen(
    data: (searchData) => searchData?['works'][0]['id'].toString(),
    orElse: () => null,
  );
});

final sourceIdProvider = Provider<String?>((ref) {
  final searchText = ref.watch(searchTextProvider);
  if (searchText == null) {
    return null;
  }
  if (searchText.startsWith('RJ')) {
    return searchText;
  }

  final idSearchResult = ref.watch(idSearchResultProvider);
  return idSearchResult.maybeWhen(
    data: (searchData) => searchData?['works'][0]['source_id'].toString(),
    orElse: () => null,
  );
});

final rootFolderProvider = StateProvider<Folder?>((ref) {
  final rawTracks = ref.watch(rawTracksProvider);
  final sourceId = ref.watch(sourceIdProvider);
  if (sourceId == null) {
    return null;
  }

  return rawTracks.maybeWhen(
      data: (data) {
        if (data == null) {
          return null;
        }
        return Folder(id: sourceId, title: sourceId)
          ..children = getTrackItems(data);
      },
      orElse: () => null);
});

final dlStatusProvider = StateProvider((ref) => DownloadStatus.notStarted);

final processProvider = StateProvider<double>((ref) => 0);

final currentFileNameProvider = StateProvider<String>((ref) => '');

final currentDlNoProvider = StateProvider<int>((ref) => 0);
final totalTaskCntProvider = StateProvider<int>((ref) => 0);
