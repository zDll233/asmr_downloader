import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/pages/downloader/search_result/components/download_track_item.dart';
import 'package:asmr_downloader/pages/downloader/search_result/components/get_track_items.dart';
import 'package:asmr_downloader/pages/downloader/search_result/components/voice_work_dir_and_cover.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/tracks.dart';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class TracksView extends ConsumerWidget {
  const TracksView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final rj = ref.watch(rjProvider);
    final title = ref.watch(titleProvider);
    final cvLs = ref.watch(cvLsProvider);
    final coverUrl = ref.watch(coverUrlProvider);
    final appWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: appWidth * 0.6,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: Center(
          child: tracks.when(
            data: (data) {
              if (data == null) {
                return Text('No tracks');
              }
              final rootFolder = Folder(title: rj)
                ..depth = 0
                ..children = getTrackItems(data);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.pink[200]),
                      onPressed: () {
                        final downloadPath = ref.read(downloadPathProvider);
                        final voiceWorkDirName = '${cvLs.join('&')}-$title';
                        final rootFolder = ref.read(rootFolderProvider);

                        voiceWorkDirAndCover(
                            ref, title, cvLs, coverUrl, downloadPath);
                        downloadTrackItem(ref, rootFolder,
                            p.join(downloadPath, voiceWorkDirName));
                      },
                      child:
                          Text('下载', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  Expanded(child: Tracks(rootFolder: rootFolder)),
                ],
              );
            },
            error: (error, _) => Text('Error: $error'),
            loading: () => const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
