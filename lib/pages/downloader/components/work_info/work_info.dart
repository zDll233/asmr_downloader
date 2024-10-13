import 'dart:io';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
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
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blueGrey),
                          onPressed: () {
                            // 创建目录
                            final baseDirPath = r'E:\Media\ACG\音声\Marked';
                            // cv1&cv2&...&cvn-title
                            final dirName = '${cvLs.join('&')}-$title';
                            final targetDirPath = p.join(
                                baseDirPath, dirName, ref.read(rjProvider));
                            Directory(targetDirPath)
                                .createSync(recursive: true);

                            // 下载cover
                            String coverPath =
                                p.join(targetDirPath, 'cover.jpg');
                            final dio = Dio();
                            dio.download(coverUrl, coverPath);
                          },
                          child: Text(
                            '创建目录&下载cover',
                            style: TextStyle(color: Colors.white70),
                          )),
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
}
