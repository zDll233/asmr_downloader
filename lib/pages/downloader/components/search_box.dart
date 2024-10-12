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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            SizedBox(
              width: 200,
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
            Consumer(builder: (context, ref, _) {
              return IconButton(
                onPressed: () =>
                    ref.read(rjProvider.notifier).state = _inputText,
                icon: Icon(Icons.search),
              );
            }),
          ],
        ),
        SizedBox(height: 20),
        Consumer(builder: (context, ref, _) {
          return Text(
            '搜索: ${ref.watch(rjProvider)}',
            style: TextStyle(color: _color),
          );
        }),
      ],
    );
  }
}
