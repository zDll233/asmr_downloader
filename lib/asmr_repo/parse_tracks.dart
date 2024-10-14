import 'package:asmr_downloader/model/track_item.dart';
import 'package:collection/collection.dart';

List<TrackItem> getTrackItems(List<dynamic> tracks,
    {List<String> basePathLs = const []}) {
  List<TrackItem> trackItems = [];
  for (final track in tracks) {
    final title = track['title'];
    final type = track['type'];
    final newPathLs = basePathLs + [title];
    if (type == 'folder') {
      Folder folder = Folder(title: title);
      folder.pathLs = newPathLs;

      folder.children = getTrackItems(
        track['children'],
        basePathLs: folder.pathLs,
      );
      trackItems.add(folder);
    } else {
      FileAsset fileAsset = FileAsset(
        hash: track['hash'],
        type: type,
        title: title,
        mediaStreamUrl: track['mediaStreamUrl'],
        mediaDownloadUrl: track['mediaDownloadUrl'],
        size: track['size'],
      );
      fileAsset.pathLs = newPathLs;
      trackItems.add(fileAsset);
    }
  }

  sortTrackItems(trackItems);

  return trackItems;
}

// sort trackItems by type: folder, fileAsset
// when type is the same, sort by title
void sortTrackItems(List<TrackItem> trackItems) {
  trackItems.sort((a, b) {
    if (a is Folder && b is! Folder) {
      return -1;
    } else if (a is! Folder && b is Folder) {
      return 1;
    } else {
      return compareNatural(a.title, b.title);
    }
  });
}
