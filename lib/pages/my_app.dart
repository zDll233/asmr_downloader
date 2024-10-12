import 'dart:ui';

import 'package:asmr_downloader/pages/components/initialization.dart';
import 'package:asmr_downloader/pages/window_title_bar/window_title_bar.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Initialization(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
            brightness: Brightness.dark,
          )),
          scrollBehavior: MyCustomScrollBehavior(),
          home: const Scaffold(
              backgroundColor: Colors.transparent,
              body: FocusScope(
                canRequestFocus: false,
                child: Column(
                  children: [
                    WindowTitleBar(),
                  ],
                ),
              ))),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // default
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        // enable mouse && trackpad
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}
