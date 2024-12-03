import 'package:asmr_downloader/pages/downloader/search_result/work_info/components/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrCircleName extends ConsumerWidget {
  const AsmrCircleName({super.key, required this.verticalPadding});
  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleName = ref.watch(circleNameProvider);
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding),
      child: CopyableTextBox(
        text: circleName,
        textStyle: TextStyle(color: Color.fromRGBO(158, 158, 158, 1)),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
