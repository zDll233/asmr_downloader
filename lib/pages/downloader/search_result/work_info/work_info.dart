import 'package:asmr_downloader/pages/downloader/search_result/work_info/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/services/ui/ui_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class WorkInfo extends ConsumerWidget {
  const WorkInfo({super.key, this.horizontalPadding = 20.0});
  final double horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    final workInfoLoadingState = ref.watch(workInfoLoadingStateProvider);
    return SizedBox(
      width: appWidth * 0.4,
      child: Padding(
        padding:
            EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
        child: workInfoLoadingState.when(
          data: (data) {
            if (data == null) {
              return const Text('No work info');
            }
            return ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cover(ref.read(coverUrlProvider)),
                    _title(ref.read(titleProvider), context),
                    _miscInfo(
                      ref.read(releaseDateProvider),
                      ref.read(dlCountProvider),
                    ),
                    _tag(ref.read(tagLsProvider)),
                    _cv(ref.read(cvLsProvider)),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(child: const CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _cover(String coverUrl) {
    return Consumer(
      builder: (context, ref, child) {
        final coverBytes = ref.watch(coverBytesProvider);
        return coverBytes.when(
          data: (bytes) {
            if (bytes == null) {
              return const Icon(Icons.error, color: Colors.red);
            }
            return FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: MemoryImage(bytes));
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) {
            Log.error('Load cover image failed\n'
                'cover url: $coverUrl\n'
                'error: $error');
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      },
    );
  }

  static const _verticalPadding = 10.0;

  Widget _title(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _verticalPadding),
      child: CopyableTextBox(
        text: title,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _miscInfo(String releaseData, int dlCount) {
    return Padding(
      padding: const EdgeInsets.only(top: _verticalPadding),
      child: Row(
        children: [
          Text(releaseData),
          const SizedBox(width: 20.0),
          Text('销量: $dlCount'),
        ],
      ),
    );
  }

  Widget _tag(List<String> tagLsvLs) {
    return Padding(
      padding: const EdgeInsets.only(top: _verticalPadding),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        children: [
          ...tagLsvLs.map((e) => Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: CopyableTextBox(
                  text: e,
                  textStyle: const TextStyle(color: Colors.black),
                  backgroundColor: Color.fromRGBO(224, 224, 224, 1),
                  borderRadius: 10.0,
                ),
              ))
        ],
      ),
    );
  }

  Widget _cv(List<String> cvLs) {
    return Padding(
      padding: const EdgeInsets.only(
          top: _verticalPadding, bottom: _verticalPadding),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        children: [
          ...cvLs.map((e) => Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: CopyableTextBox(
                  text: e,
                  backgroundColor: Color.fromRGBO(50, 150, 136, 1),
                ),
              ))
        ],
      ),
    );
  }
}
