import 'package:asmr_downloader/pages/downloader/search_result/tracks_view/middle_ellipsis_text.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _lPadding = 20.0;

class Tracks extends ConsumerStatefulWidget {
  const Tracks({super.key, required this.rootFolder});
  final Folder rootFolder;

  @override
  ConsumerState<Tracks> createState() => TracksState();
}

class TracksState extends ConsumerState<Tracks> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: trackExpansion(widget.rootFolder),
    );
  }

  List<Widget> trackExpansion(TrackItem track) {
    List<Widget> trackWidgets = [];
    if (track is Folder) {
      trackWidgets.add(
        Padding(
          padding: EdgeInsets.only(left: _lPadding),
          child: ExpansionTile(
            leading: Icon(Icons.folder, color: Color(0xFFF9C100)),
            trailing: Checkbox(
                value: track.selected,
                onChanged: (bool? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    track.setSelection(newValue);
                  });
                  ref.read(rootFolderProvider.notifier).state =
                      widget.rootFolder;
                }),
            title: Text(track.title),
            children: track.children
                .expand((child) => trackExpansion(child))
                .toList(),
          ),
        ),
      );
    } else {
      // FileAsset
      trackWidgets.add(
        Padding(
          padding: EdgeInsets.only(left: _lPadding),
          child: CheckboxListTile(
            value: track.selected,
            onChanged: (bool? newValue) {
              if (newValue == null) return;
              setState(() {
                track.selected = newValue;
              });
              ref.read(rootFolderProvider.notifier).state = widget.rootFolder;
            },
            title: Row(
              children: [
                getIconFromType(track.type),
                SizedBox(width: 10.0),
                ...ellipsisInMiddle(track.title),
              ],
            ),
          ),
        ),
      );
    }
    return trackWidgets;
  }

  Icon getIconFromType(String type) {
    switch (type) {
      case 'audio':
        return Icon(Icons.music_note, color: Colors.blue);
      case 'image':
        return Icon(Icons.image, color: Colors.green);
      case 'text':
        return Icon(Icons.text_snippet, color: Colors.grey);
      default:
        return Icon(Icons.error, color: Colors.white);
    }
  }
}
