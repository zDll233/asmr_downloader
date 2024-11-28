import 'dart:io';

import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/asmr_api.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/api_providers.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/asmr_repo/providers/work_info_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class DownloadManager {
  final WidgetRef ref;
  late final AsmrApi _api;
  DownloadManager({required this.ref}) : _api = ref.read(asmrApiProvider);

  Future<void> run() async {
    ref.read(dlStatusProvider.notifier).state = DownloadStatus.downloading;

    ref.read(currentDlNoProvider.notifier).state = 0;

    final targetDirPath = ref.read(targetDirPathProvider);
    await Directory(targetDirPath).create(recursive: true);

    // root Folder cnt
    int rootFolderTaskCnt = 0;
    final rootFolderSnapshot = ref.read(rootFolderProvider)?.copyWith();
    if (rootFolderSnapshot == null) {
      Log.fatal('Download failed: Root folder is null');
    } else {
      rootFolderTaskCnt = countTotalTask(rootFolderSnapshot);
      ref.read(totalTaskCntProvider.notifier).state = rootFolderTaskCnt;
    }

    // download cover
    if (ref.read(dlCoverProvider)) {
      ref.read(totalTaskCntProvider.notifier).state++;
      final rj = ref.read(rjProvider);
      await _downloadCover(rj, p.join(targetDirPath, rj));
    }

    // download root folder
    if (rootFolderTaskCnt > 0) {
      await _downloadTrackItem(rootFolderSnapshot!, targetDirPath);
    }

    ref.read(dlStatusProvider.notifier).state = DownloadStatus.completed;
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
  Future<void> _downloadCover(String rj, String rjDirPath) async {
    try {
      final coverUrl = ref.read(coverUrlProvider);
      final response = await _api.head(coverUrl);
      final coverSize = int.parse(response.headers.value('Content-Length')!);

      FileAsset coverFile = FileAsset(
        id: '${rj}_cover',
        type: 'image',
        title: '${rj}_cover.jpg',
        mediaStreamUrl: coverUrl,
        mediaDownloadUrl: coverUrl,
        size: coverSize,
        savePath: p.join(rjDirPath, '${rj}_cover.jpg'),
      )..selected = true;

      await _downloadTrackItem(coverFile, rjDirPath);
    } catch (e) {
      Log.error('Download cover failed: ${rj}_cover.jpg\nerror: $e');
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

    Log.info('Start downloading: ${task.title}\n'
        'URL: ${task.mediaDownloadUrl}\n'
        'Save path: ${task.savePath}');

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

      Log.info('Download completed: ${task.title}');
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
          response = await _api.download(
            urlPath,
            savePath,
            cancelToken: cancelToken,
            deleteOnError: false,
            onReceiveProgress: onReceiveProgress,
          );
        } else if (downloadedBytes < fileSize) {
          Log.info(
              'Resume downloading: $fileName\ndownloadedBytes: $downloadedBytes, fileSize: $fileSize');
          response = await _api.download(
            urlPath,
            tmpSavePath,
            cancelToken: cancelToken,
            deleteOnError: false,
            onReceiveProgress: (received, total) {
              onReceiveProgress!(received + downloadedBytes, fileSize);
            },
            options:
                Options(headers: {'range': 'bytes=$downloadedBytes-$fileSize'}),
          );
        } else if (downloadedBytes == fileSize) {
          return true;
        } else {
          // downloadedBytes > fileSize

          Log.error('Download failed:$fileName\nerror: downloadedBytes > fileSize');
          return false;
        }
      } catch (e) {
        Log.warning('Download failed: $fileName\nerror: $e');
        await Future.delayed(Duration(seconds: 3));
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
