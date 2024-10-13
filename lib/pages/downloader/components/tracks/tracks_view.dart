import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/pages/downloader/components/tracks/get_track_items.dart';
import 'package:asmr_downloader/pages/downloader/components/tracks/tracks.dart';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksView extends ConsumerWidget {
  const TracksView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final rj = ref.watch(rjProvider);
    final appWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: appWidth * 0.5,
        child: Center(
          child: tracks.when(
            data: (data) {
              if (data == null) {
                return Text('No tracks');
              }
              final rootFolder = Folder(title: rj)
                ..depth = 0
                ..children = getTrackItems(data);
              return Tracks(rootFolder: rootFolder);
            },
            error: (error, _) => Text('Error: $error'),
            loading: () => const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
