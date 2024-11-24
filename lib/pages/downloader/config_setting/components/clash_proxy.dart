import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/common/config.dart';
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
            Text('clash代理'),
            Checkbox(
              value: clashProxy,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(clashProxyProvider.notifier).state = value;
                ref.read(configFileProvider).addOrUpdate({'clashProxy': value});

                ref.read(asmrApiProvider).proxy =
                    value ? '127.0.0.1:7890' : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
