import 'package:asmr_downloader/pages/downloader/search_result/work_info/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
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
                  FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(coverUrl),
                    imageErrorBuilder: (context, error, stackTrace) {
                      Log.error(
                          'Failed to load cover image: $error\ncover url: $coverUrl');
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: CopyableTextBox(
                        text: title,
                        textStyle: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.0,
                    children: [
                      ...cvLs.map((e) => CopyableTextBox(
                            text: e,
                            backgroundColor: Color.fromRGBO(50, 150, 136, 1),
                          ))
                    ],
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
