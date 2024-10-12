import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MoveWindow extends StatelessWidget {
  const MoveWindow({
    super.key,
    this.text,
  });

  final Text? text;

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: SizedBox(
        height: double.infinity,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16),
              child: text ?? Container(),
            ),
          ],
        ),
      ),
    );
  }
}
