import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/repository/asmr_repo/asmr_api.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadPathProvider =
    StateProvider<String>((ref) => r'E:\Media\ACG\音声\Marked');

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
  return Folder(title: '');
});
