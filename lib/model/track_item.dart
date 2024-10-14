import 'package:dio/dio.dart';

class TrackItem {
  String type;
  String title;
  List<String> pathLs = [];
  bool selected = false;

  TrackItem({
    required this.type,
    required this.title,
  });
}

class Folder extends TrackItem {
  List<TrackItem> children = [];
  Folder({
    super.type = 'folder',
    required super.title,
  });

  void setSelection(bool value) {
    selected = value;
    for (final child in children) {
      if (child is Folder) {
        child.setSelection(value);
      } else {
        child.selected = value;
      }
    }
  }
}

enum DownloadStatus { notStarted, downloading, completed, failed, canceled }

class FileAsset extends TrackItem {
  String hash;
  String mediaStreamUrl;
  String mediaDownloadUrl;
  int size;

  String savePath;
  DownloadStatus status;
  double progress;
  CancelToken cancelToken;

  FileAsset({
    required super.type,
    required super.title,
    required this.mediaStreamUrl,
    required this.mediaDownloadUrl,
    required this.size,
    required this.hash,
    this.savePath = '',
    this.status = DownloadStatus.notStarted,
    this.progress = 0.0,
    CancelToken? cancelToken,
  }) : cancelToken = cancelToken ?? CancelToken();
}
