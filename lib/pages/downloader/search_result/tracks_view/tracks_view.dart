import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/download_process.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/tracks.dart';
import 'package:asmr_downloader/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksView extends ConsumerWidget {
  const TracksView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    final tracksLoadingState = ref.watch(tracksLoadingStateProvider);
    return SizedBox(
      width: appWidth * 0.6,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: tracksLoadingState.when(
          data: (_) {
            final rootFolder = ref.read(rootFolderProvider);
            return rootFolder == null
                ? const Text('No tracks')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16.0, bottom: 10.0),
                        child: DownloadProcess(appWidth: appWidth),
                      ),
                      Expanded(child: Tracks(rootFolder: rootFolder)),
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
