import 'dart:io';
import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class WorkInfo extends StatelessWidget {
  const WorkInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: appWidth * 0.3,
        child: Consumer(builder: (context, ref, _) {
          final workInfo = ref.watch(workInfoProvider);
          return Center(
            child: workInfo.when(
              data: (data) {
                if (data == null) {
                  return const Text('No work info');
                }

                final title = ref.read(titleProvider);
                final cvLs = ref.read(cvLsProvider);
                final coverUrl = ref.read(coverUrlProvider);

                return Column(
                  children: [
                    Image.network(coverUrl),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 8.0,
                      children: [...cvLs.map((e) => Text(e))],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blueGrey),
                          onPressed: () {
                            final downloadPath = ref.read(downloadPathProvider);
                            voiceWorkDirAndCover(
                                ref, title, cvLs, coverUrl, downloadPath);
                          },
                          child: Text(
                            '创建目录&下载cover',
                            style: TextStyle(color: Colors.white70),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.pink[200]),
                        onPressed: () {
                          final downloadPath = ref.read(downloadPathProvider);
                          final voiceWorkDirName = '${cvLs.join('&')}-$title';
                          final rootFolder = ref.read(rootFolderProvider);

                          voiceWorkDirAndCover(
                              ref, title, cvLs, coverUrl, downloadPath);
                          downloadTrackItem(rootFolder,
                              p.join(downloadPath, voiceWorkDirName));
                        },
                        child:
                            Text('下载', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          );
        }),
      ),
    );
  }

  Future<void> voiceWorkDirAndCover(
    WidgetRef ref,
    String title,
    List<String> cvLs,
    String coverUrl,
    String downloadPath,
  ) async {
    // cv1&cv2&...&cvn-title
    final dirName = '${cvLs.join('&')}-$title';
    final rjDirPath = p.join(
      downloadPath,
      dirName,
      ref.read(rjProvider),
    );
    Log.info('Creating directory $rjDirPath');
    Directory(rjDirPath).createSync(recursive: true);

    // 下载cover
    String coverPath = p.join(rjDirPath, 'cover.jpg');
    await Dio().download(coverUrl, coverPath);
    Log.info('Download cover to $coverPath successfully');
  }
}

void downloadTrackItem(TrackItem trackItem, String targetDirPath) {
  if (trackItem is Folder) {
    final dirPath = p.join(targetDirPath, trackItem.title);
    Log.info('Creating directory $dirPath');
    Directory(dirPath).createSync(recursive: true);
    for (final child in trackItem.children) {
      downloadTrackItem(child, dirPath);
    }
  } else if (trackItem is FileAsset) {
    final dio = Dio();
    final targetPath = p.join(targetDirPath, trackItem.title);
    if (trackItem.selected) {
      Log.info('Downloading ${trackItem.title} to $targetPath');
      dio.download(trackItem.mediaDownloadUrl, targetPath);
    } else {
      Log.info('Skipping ${trackItem.title}');
    }
  }
}
