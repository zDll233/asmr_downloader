import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/pages/downloader/components/tracks/get_track_items.dart';
import 'package:asmr_downloader/repository/asmr_repo/asmr_api.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rjProvider = StateProvider<String>((ref) => '');

final asmrApiProvider = Provider<AsmrApi>((ref) {
  return AsmrApi(
    name: 'moondasscry',
    password: 'lzd951413',
  );
});

final workInfoProvider = FutureProvider((ref) async {
  final api = ref.watch(asmrApiProvider);
  final rj = ref.watch(rjProvider);

  if (rj.isEmpty) {
    return Future.value(null);
  }
  Log.info('fetch workInfo: "$rj"');
  return api.getWorkInfo(rj: rj);
});

final tracksProvider = FutureProvider((ref) async {
  final api = ref.watch(asmrApiProvider);
  final rj = ref.watch(rjProvider);

  if (rj.isEmpty) {
    return Future.value(null);
  }
  Log.info('fetch tracks: "$rj"');
  return api.getTracks(rj: rj);
});

final titleProvider = Provider<String>((ref) {
  final workInfo = ref.watch(workInfoProvider);
  return workInfo.maybeWhen(
    data: (data) {
      if (data == null) {
        return '';
      }
      return data['title'].toString();
    },
    orElse: () => '',
  );
});

final cvLsProvider = Provider<List<String>>((ref) {
  final workInfo = ref.watch(workInfoProvider);
  return workInfo.maybeWhen(
    data: (data) {
      if (data == null) {
        return [];
      }
      return (data['vas'] as List).map((e) => e['name'].toString()).toList();
    },
    orElse: () => [],
  );
});

final coverUrlProvider = Provider<String>((ref) {
  final workInfo = ref.watch(workInfoProvider);
  return workInfo.maybeWhen(
    data: (data) {
      if (data == null) {
        return '';
      }
      return data['mainCoverUrl'].toString();
    },
    orElse: () => '',
  );
});

final rootFolderProvider = StateProvider<Folder>((ref) {
  final rj = ref.read(rjProvider);
  final trackItemsAsync = ref.watch(tracksProvider);
  final emptyFolder = Folder(title: 'root');
  return trackItemsAsync.maybeWhen(
    data: (data) {
      if (data == null) {
        return emptyFolder;
      }
      return Folder(title: rj)
        ..depth = 0
        ..children = getTrackItems(data);
    },
    orElse: () => emptyFolder,
  );
});
