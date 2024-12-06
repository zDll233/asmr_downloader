import 'package:asmr_downloader/pages/components/middle_ellipsis_text.dart';
import 'package:asmr_downloader/pages/window_title_bar/move_window.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/models/track_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tracks extends ConsumerStatefulWidget {
  const Tracks({
    super.key,
    required this.rootFolder,
    this.tracksLPadding = 20.0,
  });
  final Folder rootFolder;
  final double tracksLPadding;

  @override
  ConsumerState<Tracks> createState() => TracksState();
}

class TracksState extends ConsumerState<Tracks> {
  @override
  Widget build(BuildContext context) {
    final trackExpansionLs = trackExpansion(widget.rootFolder);
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => trackExpansionLs[index],
            childCount: trackExpansionLs.length,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: MoveWindow(
            //this container will fill the remaining space in the ViewPort
            child: Container(),
          ),
        ),
      ],
    );
  }

  List<Widget> trackExpansion(TrackItem track) {
    List<Widget> trackWidgets = [];
    if (track is Folder) {
      trackWidgets.add(
        Padding(
          padding: EdgeInsets.only(left: widget.tracksLPadding),
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
          padding: EdgeInsets.only(left: widget.tracksLPadding),
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
