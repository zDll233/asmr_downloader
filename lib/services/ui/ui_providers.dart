import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workInfoLoadingStateProvider = Provider<AsyncValue>((ref) {
  final idSearchResultFuture = ref.watch(idSearchResultProvider);
  final workInfoFuture = ref.watch(workInfoProvider);

  if (idSearchResultFuture is AsyncError) {
    return AsyncError(
        idSearchResultFuture.error!, idSearchResultFuture.stackTrace!);
  }
  if (workInfoFuture is AsyncError) {
    return AsyncError(workInfoFuture.error!, workInfoFuture.stackTrace!);
  }

  if (idSearchResultFuture is AsyncLoading || workInfoFuture is AsyncLoading) {
    return AsyncLoading();
  }

  // both AsyncData
  return AsyncData(workInfoFuture.value);
});

final tracksLoadingStateProvider = Provider<AsyncValue>((ref) {
  final idSearchResultFuture = ref.watch(idSearchResultProvider);
  final rawTracks = ref.watch(rawTracksProvider);

  if (idSearchResultFuture is AsyncError) {
    return AsyncError(
        idSearchResultFuture.error!, idSearchResultFuture.stackTrace!);
  }
  if (rawTracks is AsyncError) {
    return AsyncError(rawTracks.error!, rawTracks.stackTrace!);
  }

  if (idSearchResultFuture is AsyncLoading || rawTracks is AsyncLoading) {
    return AsyncLoading();
  }

  // both AsyncData
  return AsyncData(rawTracks.value);
});
