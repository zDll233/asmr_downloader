import 'package:asmr_downloader/pages/downloader/search_result/tracks/tracks_view.dart';
import 'package:asmr_downloader/pages/downloader/search_result/work_info/work_info.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkInfo(),
          TracksView(),
        ],
      ),
    );
  }
}
