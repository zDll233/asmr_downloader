import 'package:asmr_downloader/pages/downloader/config_setting/config_settings.dart';
import 'package:asmr_downloader/pages/downloader/search_box/search_box.dart';
import 'package:asmr_downloader/pages/downloader/search_result/search_result.dart';
import 'package:flutter/material.dart';

class Downloader extends StatelessWidget {
  const Downloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SearchBox(),
              ConfigSettings(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Text('Search Result',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          SearchResult(),
        ],
      ),
    );
  }
}
