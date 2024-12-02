import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AsyncValue<T> combineStates<T>(
  AsyncValue searchResult,
  AsyncValue<T> data,
) {
  if (searchResult.isRefreshing || data.isRefreshing) {
    return const AsyncLoading();
  }

  return searchResult.when(
    data: (_) => data,
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
}

final workInfoLoadingStateProvider = Provider<AsyncValue>((ref) {
  final searchResultFuture = ref.watch(searchResultProvider);
  final workInfoFuture = ref.watch(workInfoProvider);
  return combineStates(searchResultFuture, workInfoFuture);
});

final tracksLoadingStateProvider = Provider<AsyncValue>((ref) {
  final searchResultFuture = ref.watch(searchResultProvider);
  final rawTracksFuture = ref.watch(rawTracksProvider);
  return combineStates(searchResultFuture, rawTracksFuture);
});
