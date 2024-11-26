import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/services/download/download_manager.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadProcess extends StatelessWidget {
  const DownloadProcess({super.key, required this.appWidth});

  final double appWidth;

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Consumer(
          builder: (_, WidgetRef ref, __) {
            final downloading =
                ref.watch(dlStatusProvider) == DownloadStatus.downloading;
            return TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.pink[200]),
              onPressed: downloading ? null : DownloadManager(ref: ref).run,
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
              width: appWidth * 0.07,
              child: Center(child: Text('$currentDl/$total')),
            );
          },
        ),
        Consumer(
          builder: (_, WidgetRef ref, __) {
            final process = ref.watch(processProvider);
            final currentFileName = ref.watch(currentFileNameProvider);
            return SizedBox(
              width: appWidth * 0.33,
              child: Stack(children: [
                LinearProgressIndicator(
                  minHeight: 30,
                  borderRadius: BorderRadius.circular(10),
                  value: process,
                ),
                Positioned(
                    top: 3.5,
                    left: 5,
                    child: SizedBox(
                      width: appWidth * 0.32,
                      child: Text(
                        currentFileName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              child:
                  Center(child: Text('${(process * 100).toStringAsFixed(2)}%')),
            );
          },
        ),
      ],
    );
  }
}
