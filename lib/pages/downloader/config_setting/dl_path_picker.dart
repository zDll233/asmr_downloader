import 'package:asmr_downloader/common/const.dart';
import 'package:asmr_downloader/download/dowbload_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadPathPicker extends ConsumerWidget {
  const DownloadPathPicker({super.key});

  final Color _color = Colors.white70;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dlPath = ref.watch(downloadPathProvider);
    return SizedBox(
      height: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                enabled: false,
                cursorColor: _color,
                decoration: InputDecoration(
                  hintText: dlPath.isEmpty ? 'pick download path' : dlPath,
                  border: OutlineInputBorder(),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: _color)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconButton(
                onPressed: () async {
                  final dlPath = await FilePicker.platform.getDirectoryPath();
                  if (dlPath == null) {
                    return;
                  }
                  ref.read(downloadPathProvider.notifier).state = dlPath;
                  ref.read(configProvider).write({'dlPath': dlPath});
                },
                icon: Icon(Icons.folder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
