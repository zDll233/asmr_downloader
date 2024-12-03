import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/tracks_view.dart';
import 'package:asmr_downloader/pages/downloader/search_result/work_info/work_info.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});
  static const _horizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkInfo(horizontalPadding: _horizontalPadding),
          TracksView(horizontalPadding: _horizontalPadding),
        ],
      ),
    );
  }
}
