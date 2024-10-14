import 'package:asmr_downloader/download/dowbload_providers.dart';
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
              width: 200,
              child: TextField(
                controller: _controller,
                cursorColor: _color,
                decoration: InputDecoration(
                  hintText: 'input RJ code',
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
              child: IconButton(
                onPressed: () {
                  final rj = _inputText.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                  ref.read(rjProvider.notifier).state = rj;
                },
                icon: Icon(Icons.search),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
