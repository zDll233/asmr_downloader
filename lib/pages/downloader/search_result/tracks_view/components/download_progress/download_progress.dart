import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/components/download_progress/download_button.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/components/download_progress/download_count.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/components/download_progress/progress_bar.dart';
import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/components/download_progress/progress_percentage.dart';
import 'package:flutter/material.dart';

class DownloadProgress extends StatelessWidget {
  const DownloadProgress({super.key, required this.tracksLPadding});
  final double tracksLPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = MediaQuery.of(context).size.width * 0.01;
    return Padding(
      padding: EdgeInsets.only(left: tracksLPadding, bottom: 10.0),
      child: Row(
        children: [
          DownloadButton(),
          SizedBox(width: spacing),
          ProgressBar(),
          SizedBox(width: spacing),
          ProgressPercentage(),
          Spacer(),
          DownloadCount(),
        ],
      ),
    );
  }
}
