import 'package:asmr_downloader/download/download_providers.dart';
import 'package:asmr_downloader/model/track_item.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rootFolderProvider.notifier).state = widget.rootFolder;
    });
  }

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
            leading: Icon(Icons.folder),
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
