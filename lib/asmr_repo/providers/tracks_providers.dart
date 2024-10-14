import 'package:asmr_downloader/download/dowbload_providers.dart';
import 'package:asmr_downloader/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tracksProvider = FutureProvider((ref) async {
  final api = ref.watch(asmrApiProvider);
  final rj = ref.watch(rjProvider);

  if (rj.isEmpty) {
    return Future.value(null);
  }
  Log.info('fetch tracks: "$rj"');
  return api.getTracks(rj: rj);
});
