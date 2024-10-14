import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

class Log {
  static final Log _instance = Log._internal();

  late final Logger _logger;
  final Logger _simpleLogger = Logger(printer: PrettyPrinter(methodCount: 0));

  // named constructor
  Log._internal() {
    final File logFile = File(p.join('debug', 'asmr_downloader.log'));
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }

    _logger = kDebugMode
        ? Logger(
            printer: PrettyPrinter(
              methodCount: 2,
              dateTimeFormat: DateTimeFormat.dateAndTime,
            ),
          )
        : Logger(
            filter: ProductionFilter(),
            printer: PrettyPrinter(
                methodCount: 0,
                colors: false,
                dateTimeFormat: DateTimeFormat.dateAndTime),
            output: FileOutput(file: logFile),
            level: Level.info,
          );
  }

  factory Log() => _instance;

  // 提供静态方法获取 Logger 实例
  static Logger get logger => _instance._logger;

  static void trace(String message) {
    _instance._logger.t(message);
  }

  static void t(String message) {
    _instance._simpleLogger.t(message);
  }

  static void debug(String message) {
    _instance._logger.d(message);
  }

  static void d(String message) {
    _instance._simpleLogger.d(message);
  }

  static void info(String message) {
    _instance._logger.i(message);
  }

  static void i(String message) {
    _instance._simpleLogger.i(message);
  }

  static void warning(String message) {
    _instance._logger.w(message);
  }

  static void w(String message) {
    _instance._simpleLogger.w(message);
  }

  static void error(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance._logger.e(
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void e(String message) {
    _instance._simpleLogger.e(message);
  }

  static void fatal(String message) {
    _instance._logger.f(message);
  }

  static void f(String message) {
    _instance._simpleLogger.f(message);
  }
}
