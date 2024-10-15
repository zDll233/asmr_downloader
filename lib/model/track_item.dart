import 'package:dio/dio.dart';

class TrackItem {
  String id;
  String type;
  String title;
  List<String> pathLs = [];
  bool selected = false;
  int depth = 0;

  TrackItem({
    required this.id,
    required this.type,
    required this.title,
  });
}

class Folder extends TrackItem {
  List<TrackItem> children = [];
  Folder({
    required super.id,
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

  TrackItem? search(String id) {
    for (final child in children) {
      if (child.id == id) {
        return child;
      }
      if (child is Folder) {
        final result = child.search(id);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}

enum DownloadStatus { notStarted, downloading, completed, failed, canceled }

class FileAsset extends TrackItem {
  String mediaStreamUrl;
  String mediaDownloadUrl;
  int size;

  String savePath;
  DownloadStatus status;
  double progress;
  CancelToken cancelToken;

  FileAsset({
    required super.id,
    required super.type,
    required super.title,
    required this.mediaStreamUrl,
    required this.mediaDownloadUrl,
    required this.size,
    this.savePath = '',
    this.status = DownloadStatus.notStarted,
    this.progress = 0.0,
    CancelToken? cancelToken,
  }) : cancelToken = cancelToken ?? CancelToken();
}
