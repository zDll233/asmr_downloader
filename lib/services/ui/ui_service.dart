import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIService {
  WidgetRef ref;
  UIService(this.ref);

  void search(String inputText) {
    final rjNum = inputText.replaceAll(RegExp(r'[^0-9]'), '');

    if (rjNum.isEmpty) {
      return;
    }
    // update RJ
    ref.read(rjProvider.notifier).state = 'RJ$rjNum';
  }

  Future<String?> pasteAndSearch() async {
    final clipBoardText = (await Clipboard.getData('text/plain'))?.text;
    if (clipBoardText != null && clipBoardText.isNotEmpty) {
      final rjNum = clipBoardText.replaceAll(RegExp(r'[^0-9]'), '');
      if (rjNum.isEmpty) {
        return null;
      }

      // set old Rj to clipboard
      final oldRj = ref.read(rjProvider);
      if (oldRj.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: oldRj));
      }

      // update RJ
      final rj = 'RJ$rjNum';
      ref.read(rjProvider.notifier).state = rj;

      return rj;
    }
    return null;
  }
}
