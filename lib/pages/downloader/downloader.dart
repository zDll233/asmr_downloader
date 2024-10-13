import 'package:asmr_downloader/pages/downloader/components/search_box.dart';
import 'package:asmr_downloader/pages/downloader/components/search_result.dart';
import 'package:flutter/material.dart';

class Downloader extends StatelessWidget {
  const Downloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SearchBox(),
          SearchResult(),
        ],
      ),
    );
  }
}
