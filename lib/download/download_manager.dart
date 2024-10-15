import 'dart:io';

import 'package:asmr_downloader/common/config.dart';
// ignore: unused_import
import 'package:asmr_downloader/common/const.dart';
import 'package:asmr_downloader/download/download_providers.dart';
import 'package:asmr_downloader/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class DownloadManager {
  final WidgetRef ref;
  DownloadManager({required this.ref});

  final Dio _dio = Dio();

  Future<void> run() async {
    // cover + rootFolder
    ref.read(totalTaskCntProvider.notifier).state =
        totalTaskCount(ref.read(rootFolderProvider));
    await createFolder();

    final rjDirPath = ref.read(rjDirPathProvider);
    await _downloadTrackItem(ref.read(rootFolderProvider), rjDirPath);
    ref.read(currentDlProvider.notifier).state = 0;
    ref.read(totalTaskCntProvider.notifier).state = 0;
  }

  int totalTaskCount(Folder rootFolder) {
    int totalTaskCnt = 0;
    for (final child in rootFolder.children) {
      if (child is Folder) {
        totalTaskCnt += totalTaskCount(child);
      } else if (child.selected) {
        totalTaskCnt++;
      }
    }
    return totalTaskCnt;
  }

  Future<void> createFolder() async {
    final rjDirPath = ref.read(rjDirPathProvider);

    final dlCover = ref.read(dlCoverProvider);
    if(!dlCover){
      Directory(rjDirPath).createSync(recursive: true);
      return;
    }

    // 下载cover
    String coverPath = p.join(rjDirPath, 'cover.jpg');
    final coverUrl = ref.read(coverUrlProvider);
    FileAsset coverFile = FileAsset(
      id: 'cover',
      type: 'image',
      title: '下载封面',
      mediaStreamUrl: coverUrl,
      mediaDownloadUrl: coverUrl,
      size: -1,
    )..savePath = coverPath;

    try {
      await _downloadTask(coverFile);
    } catch (e) {
      Log.error('Download cover failed: $e');
    }
  }

  Future<void> _downloadTrackItem(
      TrackItem trackItem, String targetDirPath) async {
    final legalTitle = trackItem.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
    final targetPath = p.join(targetDirPath, legalTitle);
    if (trackItem is Folder) {
      for (final child in trackItem.children) {
        await _downloadTrackItem(child, targetPath);
      }
    } else if (trackItem is FileAsset) {
      if (trackItem.selected) {
        try {
          trackItem.savePath = targetPath;
          ref.read(currentDlProvider.notifier).state++;
          await _downloadTask(trackItem);
        } catch (e) {
          Log.error('Download ${trackItem.title} failed: $e');
        }
      }
    }
  }

  // 开始下载任务
  Future<void> _downloadTask(FileAsset task) async {
    task.status = DownloadStatus.downloading;
    ref.read(dlStatusProvider.notifier).state = DownloadStatus.downloading;
    try {
      ref.read(currentFileNameProvider.notifier).state = task.title;
      ref.read(processProvider.notifier).state = 0;
      // ref.read(currentDlProvider.notifier).state++;
      await _dioDownload(
        task.mediaDownloadUrl,
        task.savePath,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            task.progress = received / total;
            ref.read(processProvider.notifier).state = task.progress;
          }
        },
      );

      task.status = DownloadStatus.completed;
      ref.read(dlStatusProvider.notifier).state = DownloadStatus.completed;
      task.progress = 1.0;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        task.status = DownloadStatus.canceled;
      } else {
        task.status = DownloadStatus.failed;
      }
    } catch (e) {
      task.status = DownloadStatus.failed;
    }
  }

  Future<Response<dynamic>> _dioDownload(
    String urlPath,
    dynamic savePath, {
    int maxTry = 3,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response? response;
    int tryCount = 0;
    while (tryCount < maxTry && response == null) {
      try {
        tryCount++;
        Log.i('Current try:$tryCount\nDownloading $urlPath');
        response = await _dio.download(
          urlPath,
          savePath,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        Log.i('Downloaded $urlPath into $savePath');
      } catch (e) {
        Log.warning('Currrent try:$tryCount\nDownload failed: $e');
      }
    }
    if (response == null) {
      Log.error('Download failed after $maxTry tries');
      return Future.error('Download failed after $maxTry tries');
    } else {
      return response;
    }
  }

  // 取消下载任务
  void cancelDownload(FileAsset task) {
    if (!task.cancelToken.isCancelled) {
      task.cancelToken.cancel("下载已取消");
    }
  }

  // 暂停和恢复功能可以通过更复杂的逻辑实现，比如支持断点续传
}
