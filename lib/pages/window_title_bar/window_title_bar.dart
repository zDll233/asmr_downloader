import 'package:asmr_downloader/common/const.dart';
import 'package:asmr_downloader/pages/window_title_bar/caption_buttons/window_caption_buttons.dart';
import 'package:asmr_downloader/pages/window_title_bar/move_window.dart';
import 'package:flutter/material.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    this.title,
  });

  final Text? title;

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.transparent),
      child: SizedBox(
        width: double.infinity,
        height: titleBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MoveWindow()),
            // toolButton()
            CaptionButtons(),
          ],
        ),
      ),
    );
  }
}
