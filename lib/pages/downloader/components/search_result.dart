import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult extends ConsumerWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          SizedBox(height: 20),
          Text('Search Result'),
          Consumer(builder: (context, ref, _) {
            final workInfo = ref.watch(workInfoProvider);
            return workInfo.when(
              data: (data) {
                if (data == null) {
                  return const Text('No data');
                }

                final title = ref.read(titleProvider);
                final cvLs = ref.read(cvLsProvider);
                final coverUrl = ref.read(coverUrlProvider);

                return Column(
                  children: [
                    Text(title),
                    ...cvLs.map((e) => Text(e)),
                    Image.network(coverUrl),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          }),
        ],
      ),
    );
  }
}
