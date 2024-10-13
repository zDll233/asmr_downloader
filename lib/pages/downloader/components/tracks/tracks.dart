import 'package:asmr_downloader/model/track_item.dart';
import 'package:flutter/material.dart';

const double _lPadding = 20.0;

class Tracks extends StatefulWidget {
  const Tracks({super.key, required this.rootFolder});
  final Folder rootFolder;

  @override
  State<Tracks> createState() => TracksState();
}

class TracksState extends State<Tracks> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: trackExpansion(widget.rootFolder));
  }

  List<Widget> trackExpansion(TrackItem track) {
    List<Widget> trackWidgets = [];
    if (track is Folder) {
      trackWidgets.add(
        Padding(
          padding: EdgeInsets.only(left: _lPadding),
          child: ExpansionTile(
            leading: Icon(Icons.folder),
            trailing: Checkbox(
                value: track.selected,
                onChanged: (bool? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    track.setSelection(newValue);
                  });
                }),
            title: Text(track.title),
            children: track.children
                .expand((child) => trackExpansion(child))
                .toList(),
          ),
        ),
      );
    } else {
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
            },
            title: Row(
              children: [
                Icon(getIconForType(track.type)),
                SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    track.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return trackWidgets;
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'folder':
        return Icons.folder;
      case 'audio':
        return Icons.music_note;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.error;
    }
  }
}
