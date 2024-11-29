import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:asmr_downloader/services/ui/ui_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key});

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends ConsumerState<SearchBox> {
  final TextEditingController _controller = TextEditingController();
  final Color _color = Colors.white70;
  String _inputText = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _controller,
                cursorColor: _color,
                decoration: InputDecoration(
                  hintText: '输入RJ号',
                  border: OutlineInputBorder(),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: _color)),
                ),
                onChanged: (value) {
                  setState(() {
                    _inputText = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Consumer(
                builder: (_, WidgetRef ref, __) {
                  final dlStatus = ref.watch(dlStatusProvider);
                  return IconButton(
                    onPressed: dlStatus == DownloadStatus.downloading
                        ? null
                        : () => UIService(ref).search(_inputText),
                    icon: Icon(Icons.search),
                  );
                },
              ),
            ),
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final dlStatus = ref.watch(dlStatusProvider);
                return IconButton(
                  onPressed: dlStatus == DownloadStatus.downloading
                      ? null
                      : () async {
                          final newRj = await UIService(ref).pasteAndSearch();
                          if (newRj != null) {
                            _controller.text = newRj;
                            _inputText = newRj;
                          }
                        },
                  icon: Icon(Icons.content_paste_go),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
