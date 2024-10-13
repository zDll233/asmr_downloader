import 'package:asmr_downloader/model/track_item.dart';

List<TrackItem> getTrackItems(List<dynamic> tracks,
    {int depth = 1, String basePath = ''}) {
  List<TrackItem> trackItems = [];
  for (final track in tracks) {
    final title = track['title'];
    final type = track['type'];
    if (type == 'folder') {
      Folder folder = Folder(title: title);
      folder.depth = depth;
      folder.path = '$basePath/$title';

      folder.children = getTrackItems(track['children'],
          depth: depth + 1, basePath: folder.path);
      trackItems.add(folder);
    } else if (track['type'] == 'audio') {
      AudioAsset audioAsset = AudioAsset(
        title: track['title'],
        mediaStreamUrl: track['mediaStreamUrl'],
        mediaDownloadUrl: track['mediaDownloadUrl'],
        size: track['size'],
        duration: track['duration'],
      );
      audioAsset.depth = depth;
      audioAsset.path = '$basePath/$title';
      trackItems.add(audioAsset);
    } else if (track['type'] == 'image') {
      ImageAsset imageAsset = ImageAsset(
        title: track['title'],
        mediaStreamUrl: track['mediaStreamUrl'],
        mediaDownloadUrl: track['mediaDownloadUrl'],
        size: track['size'],
      );
      imageAsset.depth = depth;
      imageAsset.path = '$basePath/$title';
      trackItems.add(imageAsset);
    } else if (track['type'] == 'text') {
      TextAsset textAsset = TextAsset(
        title: track['title'],
        mediaStreamUrl: track['mediaStreamUrl'],
        mediaDownloadUrl: track['mediaDownloadUrl'],
        size: track['size'],
      );
      textAsset.depth = depth;
      textAsset.path = '$basePath/$title';
      trackItems.add(textAsset);
    }
  }
  return trackItems;
}
