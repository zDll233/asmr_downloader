import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workInfoProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final api = ref.watch(asmrApiProvider);
  final rj = ref.watch(rjProvider);

  if (rj.isEmpty) {
    return Future.value(null);
  }
  Log.info('fetch workInfo: "$rj"');
  return api.getWorkInfo(rj: rj);
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

// final tagLsProvider = Provider<List<String>>((ref) {
//   final workInfo = ref.watch(workInfoProvider);
//   return workInfo.maybeWhen(
//     data: (data) {
//       if (data == null) {
//         return [];
//       }
//       return (data['tags'] as List).map((e) => e['name'].toString()).toList();
//     },
//     orElse: () => [],
//   );
// });

// final releaseDateProvider = Provider<String>((ref) {
//   final workInfo = ref.watch(workInfoProvider);
//   return workInfo.maybeWhen(
//     data: (data) {
//       if (data == null) {
//         return '';
//       }
//       return data['release'].toString();
//     },
//     orElse: () => '',
//   );
// });

// final dlCountProvider = Provider<int>((ref) {
//   final workInfo = ref.watch(workInfoProvider);
//   return workInfo.maybeWhen(
//     data: (data) {
//       if (data == null) {
//         return 0;
//       }
//       return data['dl_count'] as int;
//     },
//     orElse: () => 0,
//   );
// });