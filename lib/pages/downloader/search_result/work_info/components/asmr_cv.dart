import 'package:asmr_downloader/pages/components/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrCv extends ConsumerWidget {
  const AsmrCv({super.key, required this.verticalPadding});

  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvLs = ref.watch(cvLsProvider);
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding, bottom: verticalPadding),
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
