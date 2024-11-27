import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Initialization extends ConsumerStatefulWidget {
  const Initialization({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<Initialization> createState() => _InitializationState();
}

class _InitializationState extends ConsumerState<Initialization> {
  @override
  void initState() {
    super.initState();
    // init
  }

  @override
  void dispose() {
    // dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(_initProvider);

    if (result.isLoading) {
      return const Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (result.hasError) {
      return const Text('Error initializing.');
    }

    return widget.child;
  }
}

final _initProvider = FutureProvider.autoDispose((ref) async {
  final config = await ref.read(configFileProvider).read();
  ref.read(apiHostProvider.notifier).state =
      config['apiHost'] as String? ?? 'asmr-200';
  ref.read(clashProxyProvider.notifier).state =
      config['clashProxy'] as String? ?? 'DIRECT';
  ref.read(downloadPathProvider.notifier).state =
      config['dlPath'] as String? ?? '';
  ref.read(dlCoverProvider.notifier).state =
      config['dlCover'] as bool? ?? false;


  ref.read(asmrApiProvider)
    ..setApiHost(ref.read(apiHostProvider))
    ..proxy = ref.read(clashProxyProvider);
});
