import 'package:asmr_downloader/services/asmr_repo/providers/tracks_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/utils/source_id_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class UIService {
  final Ref ref;
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

  Future<String?> search(String input) async {
    await resetProgress();

    final searchText = normalizeInput(input);
    if (!isSourceIdValid(searchText)) {
      return null;
    }

    if (searchText == ref.read(searchTextProvider)) {
      // force to refetch
      ref.invalidate(workInfoProvider);
      ref.invalidate(rawTracksProvider);
    } else {
      ref.read(searchTextProvider.notifier).state = searchText;
    }
    return searchText;
  }

  Future<String?> pasteAndSearch() async {
    final clipBoardText = (await Clipboard.getData('text/plain'))?.text;
    if (clipBoardText == null) {
      return null;
    }

    // set old sourceId to clipboard
    final oldSourceId = ref.read(sourceIdProvider);
    if (oldSourceId != null) {
      await Clipboard.setData(ClipboardData(text: oldSourceId));
    }

    return search(clipBoardText);
  }
}
