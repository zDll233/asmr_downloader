import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressPercentage extends ConsumerWidget {
  const ProgressPercentage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final process = ref.watch(processProvider);
    return Center(child: Text('${(process * 100).toStringAsFixed(2)}%'));
  }
}
