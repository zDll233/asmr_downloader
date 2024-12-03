import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableTextBox extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CopyableTextBox({
    super.key,
    required this.text,
    this.textStyle,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 5.0,
    this.padding =
        const EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await Clipboard.setData(ClipboardData(text: text)),
      child: Tooltip(
        message: '复制',
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Text(text, style: textStyle),
        ),
      ),
    );
  }
}
