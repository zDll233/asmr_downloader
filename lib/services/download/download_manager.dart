import 'dart:io';

import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/services/ui/ui_service.dart';
import 'package:asmr_downloader/utils/legal_windows_name.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'package:path/path.dart' as p;

class DownloadManager {
  final Ref ref;
  DownloadManager(this.ref);

  Future<void> run() async {
    await UIService(ref).resetProgress();
    ref.read(dlStatusProvider.notifier).state = DownloadStatus.downloading;

    final sourceId = ref.read(sourceIdProvider);
    if (sourceId == null) {
      Log.fatal('Download failed\n' 'error: sourId is null');
      return;
    }

    final targetDirPath = ref.read(targetDirPathProvider);
    if (targetDirPath == '-') {
      Log.warning('Download failed: $sourceId\n'
          'error: Target download path is empty, which means you have to start downloading after work info is loaded');
    } else {
      ref.read(currentDlNoProvider.notifier).state = 0;

      // root Folder cnt
      int rootFolderTaskCnt = 0;
      final rootFolderSnapshot = ref.read(rootFolderProvider)?.copyWith();
      if (rootFolderSnapshot == null) {
        Log.fatal('Download failed: $sourceId\n' 'error: rootFolder is null');
      } else {
        rootFolderTaskCnt = countTotalTask(rootFolderSnapshot);
        ref.read(totalTaskCntProvider.notifier).state = rootFolderTaskCnt;
      }

      // download cover
      if (ref.read(dlCoverProvider)) {
        ref.read(totalTaskCntProvider.notifier).state++;
        await _downloadCover(sourceId, p.join(targetDirPath, sourceId));
      }

      // download root folder
      if (rootFolderTaskCnt > 0) {
        await _downloadTrackItem(rootFolderSnapshot!, targetDirPath);
      }
    }

    ref.read(dlStatusProvider.notifier).state = DownloadStatus.completed;
    await WindowsTaskbar.setFlashTaskbarAppIcon(
      mode: TaskbarFlashMode.all | TaskbarFlashMode.timernofg,
      flashCount: 5,
      timeout: const Duration(milliseconds: 500),
    );
  }

  int countTotalTask(Folder rootFolder) {
    int totalTaskCnt = 0;
    for (final child in rootFolder.children) {
      if (child is Folder) {
        totalTaskCnt += countTotalTask(child);
      } else if (child.selected) {
        totalTaskCnt++;
      }
    }
    return totalTaskCnt;
  }

  /// 下载cover
  Future<void> _downloadCover(String sourceId, String sourceIdDirPath) async {
    final coverUrl = ref.read(coverUrlProvider);
    final int? coverSize =
        await ref.read(asmrApiProvider).tryGetContentLength(coverUrl);

    if (coverSize != null) {
      FileAsset coverFile = FileAsset(
        id: '${sourceId}_cover',
        type: 'image',
        title: '${sourceId}_cover.jpg',
        mediaStreamUrl: coverUrl,
        mediaDownloadUrl: coverUrl,
        size: coverSize,
        savePath: p.join(sourceIdDirPath, '${sourceId}_cover.jpg'),
      )..selected = true;

      await _downloadTrackItem(coverFile, sourceIdDirPath);
    } else {
      Log.error('Download cover failed: ${sourceId}_cover.jpg\n'
          'error: cover size is null');
    }
  }

  Future<void> _downloadTrackItem(
      TrackItem trackItem, String targetDirPath) async {
    final targetPath = p.join(
      targetDirPath,
      getLegalWindowsName(trackItem.title),
    );
    if (trackItem is Folder) {
      for (final child in trackItem.children) {
        await _downloadTrackItem(child, targetPath);
      }
    } else if (trackItem is FileAsset) {
      if (trackItem.selected) {
        trackItem.savePath = targetPath;
        await _downloadFileAsset(trackItem);
      }
    }
  }

  // 开始下载任务
  /// need to specify task.savePath otherwise it will be empty
  Future<void> _downloadFileAsset(FileAsset task) async {
    ref.read(currentFileNameProvider.notifier).state = task.title;
    ref.read(processProvider.notifier).state = 0;
    ref.read(currentDlNoProvider.notifier).state++;

    final dlFlag = await _resumableDownload(
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

    if (dlFlag) {
      // 如果文件已存在，不会调用onReceiveProgress，需要手动设置进度
      task.status = DownloadStatus.completed;
      task.progress = 1.0;
      ref.read(processProvider.notifier).state = 1.0;

      await WindowsTaskbar.setProgress(
          ref.read(currentDlNoProvider), ref.read(totalTaskCntProvider));
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
    final fileName = p.basename(savePath);

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

        if (downloadedBytes < fileSize) {
          if (downloadedBytes == 0) {
            Log.info('Start downloading: $fileName\n'
                'URL: $urlPath\n'
                'Save path: $savePath');
            await ref.read(asmrApiProvider).download(
                  urlPath,
                  savePath,
                  cancelToken: cancelToken,
                  deleteOnError: false,
                  onReceiveProgress: onReceiveProgress,
                );
          } else {
            Log.info('Resume downloading: $fileName\n'
                'downloadedBytes: $downloadedBytes, fileSize: $fileSize\n'
                'URL: $urlPath\n'
                'Save path: $savePath');
            await ref.read(asmrApiProvider).download(
              urlPath,
              tmpSavePath,
              cancelToken: cancelToken,
              deleteOnError: false,
              onReceiveProgress: (received, total) {
                onReceiveProgress!(received + downloadedBytes, fileSize);
              },
              options: Options(
                  headers: {'range': 'bytes=$downloadedBytes-$fileSize'}),
            );
          }
        } else if (downloadedBytes == fileSize) {
          if (fileSize == 0) {
            await file.create();
          }
          Log.info('Download completed: $fileName');
          return true;
        } else {
          // downloadedBytes > fileSize

          Log.error('Download failed: $fileName\n'
              'error: downloadedBytes > fileSize');
          return false;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 416) {
          Log.error('Download failed: $fileName\n'
              'statusCode = 416, range incorrect\n'
              'error: $e');
          return false;
        }

        Log.warning('Download failed: $fileName\n' 'error: $e');
        await Future.delayed(Duration(seconds: 3));
      } catch (e) {
        Log.error('Download failed: $fileName\n' 'Unhandled error: $e');
        return false;
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
