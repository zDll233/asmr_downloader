import 'package:asmr_downloader/repository/asmr_repo/dl_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
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
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    cursorColor: _color,
                    decoration: InputDecoration(
                      hintText: '输入RJ号',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _color)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _inputText = value;
                      });
                    },
                  ),
                ),
                Consumer(builder: (context, ref, _) {
                  return IconButton(
                    onPressed: () {
                      final rj =
                          _inputText.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      ref.read(rjProvider.notifier).state = rj;
                    },
                    icon: Icon(Icons.search),
                  );
                }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Search Result',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
