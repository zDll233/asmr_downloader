import 'package:asmr_downloader/models/track_item.dart';
import 'package:asmr_downloader/pages/window_title_bar/caption_buttons/window_button_color_theme.dart';
import 'package:asmr_downloader/pages/window_title_bar/caption_buttons/window_caption_button_icon.dart';
import 'package:asmr_downloader/services/download/download_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

const _kIconChromeClose = 'icon_chrome_close';
const _kIconChromeMaximize = 'icon_chrome_maximize';
const _kIconChromeMinimize = 'icon_chrome_minimize';
const _kIconChromeUnmaximize = 'icon_chrome_unmaximize';

const _buttonBgColorScheme = ButtonBgColorScheme(
  normal: Color.fromRGBO(255, 255, 255, 0.0),
  hovered: Color.fromRGBO(255, 255, 255, 0.1),
  pressed: Color.fromRGBO(255, 255, 255, 0.2),
);

const _buttonIconColorScheme = ButtonIconColorScheme(
  normal: Color.fromRGBO(255, 255, 255, 0.5),
  hovered: Color.fromRGBO(255, 255, 255, 1.0),
  pressed: Color.fromRGBO(255, 255, 255, 1.0),
  disabled: Color.fromRGBO(255, 255, 255, 0.5),
);

const _closeButtonBgColorScheme = ButtonBgColorScheme(
  normal: Color.fromRGBO(211, 47, 47, 0.0),
  hovered: Color.fromRGBO(211, 47, 47, 0.5),
  pressed: Color.fromRGBO(183, 28, 28, 0.5),
);

const _closeButtonIconColorScheme = ButtonIconColorScheme(
  normal: Color.fromRGBO(255, 255, 255, 0.5),
  hovered: Color.fromRGBO(255, 255, 255, 1.0),
  pressed: Color.fromRGBO(255, 255, 255, 1.0),
  disabled: Color.fromRGBO(255, 255, 255, 0.5),
);

class MinimizeButton extends ConsumerWidget {
  const MinimizeButton({
    super.key,
    this.minWidth = 46.0,
    this.minHeight = 32.0,
  });

  final double minWidth;
  final double minHeight;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WindowButton(
      iconName: _kIconChromeMinimize,
      onPressed: () async {
        bool isMinimized = await windowManager.isMinimized();
        if (isMinimized) {
          windowManager.restore();
        } else {
          windowManager.minimize();
        }
      },
      buttonBgColorScheme: _buttonBgColorScheme,
      buttonIconColorScheme: _buttonIconColorScheme,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }
}

class MaximizeButton extends StatefulWidget {
  const MaximizeButton({
    super.key,
    this.minWidth = 46.0,
    this.minHeight = 32.0,
  });

  final double minWidth;
  final double minHeight;

  @override
  State<MaximizeButton> createState() => _MaximizeButtonState();
}

class _MaximizeButtonState extends State<MaximizeButton> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: windowManager.isMaximized(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.data == true
            ? WindowButton(
                iconName: _kIconChromeUnmaximize,
                onPressed: () async {
                  windowManager.unmaximize();
                },
                buttonBgColorScheme: _buttonBgColorScheme,
                buttonIconColorScheme: _buttonIconColorScheme,
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              )
            : WindowButton(
                iconName: _kIconChromeMaximize,
                onPressed: () async {
                  windowManager.maximize();
                },
                buttonBgColorScheme: _buttonBgColorScheme,
                buttonIconColorScheme: _buttonIconColorScheme,
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              );
      },
    );
  }
}

class CloseBtn extends ConsumerWidget {
  const CloseBtn({
    super.key,
    this.minWidth = 46.0,
    this.minHeight = 32.0,
  });

  final double minWidth;
  final double minHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WindowButton(
      iconName: _kIconChromeClose,
      onPressed: () async {
        // before close
        final dlStatus = ref.read(dlStatusProvider);
        if (dlStatus == DownloadStatus.downloading) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('文件下载中'),
                content: const Text(
                    '你确定要关闭吗？下载将被取消，再次下载会继承已下载的部分。'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      windowManager.close();
                    },
                    child: const Text('关闭'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'),
                  ),
                ],
              );
            },
          );
        }
      },
      buttonBgColorScheme: _closeButtonBgColorScheme,
      buttonIconColorScheme: _closeButtonIconColorScheme,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }
}

class WindowButton extends StatefulWidget {
  const WindowButton({
    super.key,
    required this.iconName,
    required this.onPressed,
    required this.buttonBgColorScheme,
    required this.buttonIconColorScheme,
    this.minWidth = 46,
    this.minHeight = 32,
  });

  final String iconName;
  final VoidCallback? onPressed;
  final ButtonBgColorScheme buttonBgColorScheme;
  final ButtonIconColorScheme buttonIconColorScheme;
  final double minWidth;
  final double minHeight;

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  void _onEntered({required bool hovered}) {
    setState(() => _isHovering = hovered);
  }

  void _onActive({required bool pressed}) {
    setState(() => _isPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.buttonBgColorScheme.normal;
    Color iconColor = widget.buttonIconColorScheme.normal;

    if (_isHovering) {
      bgColor = widget.buttonBgColorScheme.hovered;
      iconColor = widget.buttonIconColorScheme.hovered;
    }
    if (_isPressed) {
      bgColor = widget.buttonBgColorScheme.pressed;
      iconColor = widget.buttonIconColorScheme.pressed;
    }

    return MouseRegion(
      onExit: (value) => _onEntered(hovered: false),
      onHover: (value) => _onEntered(hovered: true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onActive(pressed: true),
        onTapCancel: () => _onActive(pressed: false),
        onTapUp: (_) => _onActive(pressed: false),
        onTap: widget.onPressed,
        child: Container(
          constraints: BoxConstraints(
              minWidth: widget.minWidth, minHeight: widget.minHeight),
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Center(
            child: WindowCaptionBtnIcon(
              color: iconColor,
              createPainter: (color) {
                switch (widget.iconName) {
                  case _kIconChromeMinimize:
                    return IconChromeMinimizePainter(color!);
                  case _kIconChromeMaximize:
                    return IconChromeMaximizePainter(color!);
                  case _kIconChromeUnmaximize:
                    return IconChromeUnmaximizePainter(color!);
                  case _kIconChromeClose:
                    return IconChromeClosePainter(color!);
                  default:
                    return IconChromeClosePainter(color!);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CaptionButtons extends StatelessWidget {
  const CaptionButtons({
    super.key,
    this.buttonWidth = 46.0,
    this.buttonHeight = 32.0,
  });

  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: Row(
        children: [
          MinimizeButton(minWidth: buttonWidth),
          MaximizeButton(minWidth: buttonWidth),
          CloseBtn(minWidth: buttonWidth),
        ],
      ),
    );
  }
}
