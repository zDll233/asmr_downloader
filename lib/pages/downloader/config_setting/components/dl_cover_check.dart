import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DlCoverCheck extends ConsumerWidget {
  const DlCoverCheck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dlCover = ref.watch(dlCoverProvider);
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Text('下载封面'),
            Checkbox(
              value: dlCover,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(dlCoverProvider.notifier).state = value;
                ref.read(configFileProvider).addOrUpdate({'dlCover': value});

                Log.info('dlCover: $value');
              },
            ),
          ],
        ),
      ),
    );
  }
}
