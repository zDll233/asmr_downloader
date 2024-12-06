import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MoveWindow extends StatelessWidget {
  const MoveWindow({
    super.key,
    required this.child,
    this.moveOnChildWidget = false,
  });
  final Widget child;
  final bool moveOnChildWidget;

  @override
  Widget build(BuildContext context) {
    if (moveOnChildWidget) {
      return DragToMoveArea(child: child);
    } else {
      return Stack(
        children: [
          Positioned.fill(child: DragToMoveArea(child: Container())),
          child,
        ],
      );
    }
  }
}
