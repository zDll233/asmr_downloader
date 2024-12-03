import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrMiscInfo extends ConsumerWidget {
  const AsmrMiscInfo({super.key, required this.verticalPadding});
  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding),
      child: Row(
        children: [
          Text(ref.watch(releaseDateProvider)),
          const SizedBox(width: 20.0),
          Text('销量: ${ref.watch(dlCountProvider)}'),
        ],
      ),
    );
  }
}
