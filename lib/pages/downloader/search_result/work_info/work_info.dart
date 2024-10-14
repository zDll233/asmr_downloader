import 'package:asmr_downloader/presentation/voice_work_dir_and_cover.dart';
import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blueGrey),
                          onPressed: () {
                            final downloadPath = ref.read(downloadPathProvider);
                            final rj = ref.read(rjProvider);
                            voiceWorkDirAndCover(
                                rj, title, cvLs, coverUrl, downloadPath);
                          },
                          child: Text(
                            '创建目录&下载cover',
                            style: TextStyle(color: Colors.white70),
                          )),
                    ),
                    Image.network(coverUrl),
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
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          );
        }),
      ),
    );
  }
}
