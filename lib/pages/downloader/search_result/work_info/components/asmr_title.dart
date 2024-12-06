import 'package:asmr_downloader/pages/components/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrTitle extends ConsumerWidget {
  const AsmrTitle({super.key, required this.verticalPadding});
  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(titleProvider);
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding),
      child: CopyableTextBox(
        text: title,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
