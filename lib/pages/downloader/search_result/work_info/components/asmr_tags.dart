import 'package:asmr_downloader/pages/downloader/search_result/work_info/components/copyable_textbox.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrTags extends ConsumerWidget {
  const AsmrTags({super.key, required this.verticalPadding});
  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagLs = ref.watch(tagLsProvider);
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        children: [
          ...tagLs.map((e) => Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: CopyableTextBox(
                  text: e,
                  textStyle: const TextStyle(color: Colors.black),
                  backgroundColor: Color.fromRGBO(224, 224, 224, 1),
                  borderRadius: 15.0,
                ),
              ))
        ],
      ),
    );
  }
}
