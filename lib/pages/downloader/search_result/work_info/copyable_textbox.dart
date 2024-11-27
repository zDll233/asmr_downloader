import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableTextBox extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double borderRadius;

  final TextStyle? textStyle;

  const CopyableTextBox({
    super.key,
    required this.text,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 5.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: text));
      },
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: Tooltip(
          message: '复制到剪贴板',
          child: Container(
            padding:
                EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Text(text, style: textStyle),
          ),
        ),
      ),
    );
  }
}
