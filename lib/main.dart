import 'dart:io';

import 'package:asmr_downloader/pages/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupWindow(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    // for window acrylic, mica or transparency effects
    await Window.initialize();
    Window.setEffect(
      effect: WindowEffect.transparent,
      color: const Color(0xCC222222),
    );

    const initialSize = Size(1040, 690);
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: initialSize,
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(initialSize);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

void main(List<String> args) async {
  await setupWindow(args);
  runApp(const ProviderScope(child: MyApp()));
}
