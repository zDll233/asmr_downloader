import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/ui/ui_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiServiceProvider = Provider((ref) => UIService(ref));

AsyncValue combineStates(AsyncValue precondition, AsyncValue data) {
  if (precondition.isRefreshing || data.isRefreshing) {
    return const AsyncLoading();
  }
  return precondition.when(
    data: (_) => data,
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
}

final workInfoLoadingStateProvider = Provider<AsyncValue>(
  (ref) => combineStates(
    ref.watch(searchResultProvider),
    ref.watch(workInfoProvider),
  ),
);

final tracksLoadingStateProvider = Provider<AsyncValue>(
  (ref) => combineStates(
    ref.watch(workInfoLoadingStateProvider),
    ref.watch(rawTracksProvider),
  ),
);
