import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/download/download_manager.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class WorkInfo extends StatelessWidget {
  const WorkInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: appWidth * 0.4,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: Consumer(builder: (context, ref, _) {
          final workInfo = ref.watch(workInfoProvider);
          return workInfo.when(
            data: (data) {
              if (data == null) {
                return const Text('No work info');
              }

              final title = ref.read(titleProvider);
              final cvLs = ref.read(cvLsProvider);
              final coverUrl = ref.read(coverUrlProvider);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Consumer(
                      builder: (_, WidgetRef ref, __) {
                        final downloading = ref.watch(dlStatusProvider) ==
                            DownloadStatus.downloading;
                        return TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blueGrey),
                            onPressed: downloading
                                ? null
                                : DownloadManager(ref: ref).createFolder,
                            child: Text(
                              downloading ? '下载中' : '创建目录&下载封面',
                              style: TextStyle(color: Colors.white70),
                            ));
                      },
                    ),
                  ),
                  FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(coverUrl)),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 8.0,
                    children: [...cvLs.map((e) => Text(e))],
                  ),
                ],
              );
            },
            loading: () => Center(child: const CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          );
        }),
      ),
    );
  }
}
