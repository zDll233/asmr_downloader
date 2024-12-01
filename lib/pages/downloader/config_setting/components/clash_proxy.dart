import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClashProxy extends ConsumerWidget {
  const ClashProxy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clashProxy = ref.watch(clashProxyProvider);
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            const Text('clash代理'),
            Checkbox(
              value: clashProxy != 'DIRECT',
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                final proxy = value ? 'PROXY 127.0.0.1:7890' : 'DIRECT';
                ref.read(clashProxyProvider.notifier).state = proxy;
                ref.read(configFileProvider).addOrUpdate({'clashProxy': proxy});
                ref.read(asmrApiProvider).proxy = proxy;
              },
            ),
          ],
        ),
      ),
    );
  }
}
