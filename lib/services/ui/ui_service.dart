import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/utils/source_id_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class UIService {
  WidgetRef ref;
  UIService(this.ref);

  Future<void> resetProgress() async {
    ref.read(processProvider.notifier).state = 0;
    ref.read(currentDlNoProvider.notifier).state = 0;
    ref.read(totalTaskCntProvider.notifier).state = 0;
    ref.read(currentFileNameProvider.notifier).state = '';
    await WindowsTaskbar.setProgress(0, 0);
  }

  String normalizeInput(String sourceId) {
    return sourceId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  Future<void> search(String inputText) async {
    await resetProgress();

    final searchText = normalizeInput(inputText);
    if (searchText.isEmpty || !isSourceIdValid(searchText)) {
      return;
    }

    ref.read(searchTextProvider.notifier).state = searchText;
  }

  Future<String?> pasteAndSearch() async {
    await resetProgress();

    final clipBoardText = (await Clipboard.getData('text/plain'))?.text;
    if (clipBoardText == null) {
      return null;
    }

    final searchText = normalizeInput(clipBoardText);
    if (searchText.isEmpty || !isSourceIdValid(searchText)) {
      return null;
    }

    // set old sourceId to clipboard
    final oldSourceId = ref.read(sourceIdProvider);
    if (oldSourceId != null) {
      await Clipboard.setData(ClipboardData(text: oldSourceId));
    }

    ref.read(searchTextProvider.notifier).state = searchText;
    return searchText;
  }
}
