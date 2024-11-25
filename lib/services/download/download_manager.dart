import 'dart:io';

import 'package:asmr_downloader/common/config.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
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

    final targetDirPath = ref.read(targetDirPathProvider);
    await _downloadTrackItem(ref.read(rootFolderProvider), targetDirPath);
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
    final rj = ref.read(rjProvider);
    final rjDirPath = p.join(ref.read(targetDirPathProvider), rj);

    final dlCover = ref.read(dlCoverProvider);
    if (!dlCover) {
      Directory(rjDirPath).createSync(recursive: true);
      return;
    }

    // 下载cover
    String coverPath = p.join(rjDirPath, '${rj}_cover.jpg');
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
      await _resumableDownload(
        task.mediaDownloadUrl,
        task.savePath,
        task.size,
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

  Future<void> mergeFile(File file, File tmpFile) async {
    if (await tmpFile.exists()) {
      await file.writeAsBytes(
        await tmpFile.readAsBytes(),
        mode: FileMode.append,
      );
      await tmpFile.delete();
    }
  }

  Future<bool> _resumableDownload(
    String urlPath,
    String savePath,
    int fileSize, {
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    // ignore: unused_local_variable
    Response? response;
    final file = File(savePath);

    final tmpSavePath = '$savePath.tmp';
    final tmpFile = File(tmpSavePath);

    // 本地已经下载的文件大小
    int downloadedBytes = 0;
    int tmpFileLen = 0;

    while (true) {
      try {
        if (await file.exists()) {
          downloadedBytes = await file.length();
        }

        if (await tmpFile.exists()) {
          tmpFileLen = await tmpFile.length();
          if (tmpFileLen > 0 && tmpFileLen + downloadedBytes <= fileSize) {
            downloadedBytes += tmpFileLen;
            await mergeFile(file, tmpFile);
          } else {
            await tmpFile.delete();
          }
        }

        if (downloadedBytes == 0) {
          response = await _dio.download(
            urlPath,
            savePath,
            cancelToken: cancelToken,
            deleteOnError: false,
            onReceiveProgress: onReceiveProgress,
          );
        } else if (downloadedBytes < fileSize) {
          response = await _dio.download(
            urlPath,
            tmpSavePath,
            cancelToken: cancelToken,
            deleteOnError: false,
            onReceiveProgress: onReceiveProgress,
            options:
                Options(headers: {'range': 'bytes=$downloadedBytes-$fileSize'}),
          );
        } else if (downloadedBytes == fileSize) {
          Log.info('Download completed: $savePath');
          return true;
        } else {
          Log.error('Download failed: downloadedBytes > fileSize');
          return false;
        }
      } catch (e) {
        Log.error('Download failed: $e');
      } finally {
        await mergeFile(file, tmpFile);
      }
    }
  }

  // 取消下载任务
  void cancelDownload(FileAsset task) {
    if (!task.cancelToken.isCancelled) {
      task.cancelToken.cancel('下载已取消');
    }
  }
}
