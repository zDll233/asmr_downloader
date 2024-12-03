import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/download_progress.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/tracks.dart';
import 'package:asmr_downloader/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksView extends ConsumerWidget {
  const TracksView({super.key, this.horizontalPadding = 20.0});
  final double horizontalPadding;
  static const _tracksLPadding = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    final tracksLoadingState = ref.watch(tracksLoadingStateProvider);
    return SizedBox(
      width: appWidth * 0.6,
      child: Padding(
        padding: EdgeInsets.only(right: horizontalPadding, bottom: 10.0),
        child: tracksLoadingState.when(
          data: (_) {
            final rootFolder = ref.read(rootFolderProvider);
            return rootFolder == null
                ? const Text('No tracks')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: _tracksLPadding, bottom: 10.0),
                        child: DownloadProgress(appWidth: appWidth),
                      ),
                      Expanded(
                          child: Tracks(
                        rootFolder: rootFolder,
                        tracksLPadding: _tracksLPadding,
                      )),
                    ],
                  );
          },
          loading: () => Center(child: const CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}
