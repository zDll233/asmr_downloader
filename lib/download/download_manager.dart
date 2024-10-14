import 'package:asmr_downloader/download/dowbload_providers.dart';
import 'package:asmr_downloader/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/model/track_item.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class DownloadManager {
  final WidgetRef ref;
  final String targetDirPath;
  DownloadManager({required this.ref})
      : targetDirPath = ref.read(downloadPathProvider);

  final Dio _dio = Dio();

  Future<void> run() async {
    await downloadCover();
    await _downloadTrackItem(ref.read(rootFolderProvider), targetDirPath);
  }

  Future<void> downloadCover() async {
    final coverUrl = ref.read(coverUrlProvider);

    // 下载cover
    String coverPath = p.join(targetDirPath, 'cover.jpg');
    try {
      await _dioDownload(coverUrl, coverPath);
    } catch (e) {
      Log.error('Download cover failed: $e');
    }
  }

  Future<void> _downloadTrackItem(
      TrackItem trackItem, String targetDirPath) async {
    if (trackItem is Folder) {
      final dirPath = p.join(targetDirPath, trackItem.title);
      for (final child in trackItem.children) {
        _downloadTrackItem(child, dirPath);
      }
    } else if (trackItem is FileAsset) {
      final targetPath = p.join(targetDirPath,
          trackItem.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), ''));
      if (trackItem.selected) {
        try {
          trackItem.savePath = targetPath;
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
    try {
      await _dioDownload(
        task.mediaDownloadUrl,
        task.savePath,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            task.progress = received / total;
            // 通知UI更新（例如使用状态管理）
          }
        },
      );

      task.status = DownloadStatus.completed;
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
