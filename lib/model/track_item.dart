class TrackItem {
  String type;
  String title;
  int depth = -1;
  List<String> pathLs = [];
  bool selected = true;


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

class FileAsset extends TrackItem {
  String mediaStreamUrl;
  String mediaDownloadUrl;
  int size;
  FileAsset({
    required super.type,
    required super.title,
    required this.mediaStreamUrl,
    required this.mediaDownloadUrl,
    required this.size,
  });
}

class AudioAsset extends FileAsset {
  double duration;
  AudioAsset({
    super.type = 'audio',
    required super.title,
    required super.mediaStreamUrl,
    required super.mediaDownloadUrl,
    required this.duration,
    required super.size,
  });
}

class ImageAsset extends FileAsset {
  ImageAsset({
    super.type = 'image',
    required super.title,
    required super.mediaStreamUrl,
    required super.mediaDownloadUrl,
    required super.size,
  });
}

class TextAsset extends FileAsset {
  TextAsset({
    super.type = 'text',
    required super.title,
    required super.mediaStreamUrl,
    required super.mediaDownloadUrl,
    required super.size,
  });
}
