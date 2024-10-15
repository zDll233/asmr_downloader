import 'package:asmr_downloader/download/dowbload_providers.dart';
import 'package:asmr_downloader/download/download_manager.dart';
import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/asmr_repo/parse_tracks.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/tracks.dart';
import 'package:asmr_downloader/asmr_repo/providers/tracks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksView extends ConsumerWidget {
  const TracksView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(rawTracksProvider);
    final appWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: appWidth * 0.6,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: tracks.when(
          data: (data) {
            if (data == null) {
              return Text('No tracks');
            }
            final rj = ref.read(rjProvider);
            final rootFolder = Folder(id: rj, title: rj)
              ..children = getTrackItems(data);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                  child: Row(
                    children: [
                      Consumer(
                        builder: (_, WidgetRef ref, __) {
                          final downloading = ref.watch(dlStatusProvider) ==
                              DownloadStatus.downloading;
                          return TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.pink[200]),
                            onPressed: downloading
                                ? null
                                : DownloadManager(ref: ref).run,
                            child: Text(downloading ? '下载中' : '下载',
                                style: TextStyle(color: Colors.white70)),
                          );
                        },
                      ),
                      Spacer(),
                      Consumer(
                        builder: (_, WidgetRef ref, __) {
                          final currentDl = ref.watch(currentDlProvider);
                          final total = ref.watch(totalTaskCntProvider);
                          return SizedBox(
                            width: appWidth * 0.05,
                            child: Center(child: Text('$currentDl/$total')),
                          );
                        },
                      ),
                      Consumer(
                        builder: (_, WidgetRef ref, __) {
                          final process = ref.watch(processProvider);
                          final currentFileName =
                              ref.watch(currentFileNameProvider);
                          return SizedBox(
                            width: appWidth * 0.35,
                            child: Stack(children: [
                              LinearProgressIndicator(
                                minHeight: 30,
                                borderRadius: BorderRadius.circular(10),
                                value: process,
                              ),
                              Positioned(
                                  top: 3,
                                  left: 5,
                                  child: Text(
                                    currentFileName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ]),
                          );
                        },
                      ),
                      Consumer(
                        builder: (_, WidgetRef ref, __) {
                          final process = ref.watch(processProvider);
                          return SizedBox(
                            width: appWidth * 0.07,
                            child: Center(
                                child: Text(
                                    '${(process * 100).toStringAsFixed(2)}%')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(child: Tracks(rootFolder: rootFolder)),
              ],
            );
          },
          loading: () => Center(child: const CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
        ),
      ),
    );
  }
}
