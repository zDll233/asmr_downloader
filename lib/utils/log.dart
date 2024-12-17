import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:path/path.dart' as p;

class Log {
  // named constructor
  Log._internal() {
    _logger = kDebugMode
        ? Logger(
            printer: PrettyPrinter(
              methodCount: 0,
              dateTimeFormat: DateTimeFormat.dateAndTime,
            ),
          )
        : Logger(
            filter: ProductionFilter(),
            printer: PrettyPrinter(
                methodCount: 0,
                colors: false,
                dateTimeFormat: DateTimeFormat.dateAndTime),
            output: FileOutput(file: _getLogFile()),
            level: Level.info,
          );
  }

  File _getLogFile() {
    final logFilePath = p.join('debug', 'asmr_downloader.log');
    final logFile = File(logFilePath);

    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }

    if (logFile.lengthSync() > 1024 * 1024 * 5) {
      try {
        logFile.renameSync('$logFilePath.old');
      } catch (_) {}
    }

    return logFile;
  }

  late final Logger _logger;

  static final Log _instance = Log._internal();
  static Logger get logger => _instance._logger;

  static void trace(String message) {
    _instance._logger.t(message);
  }

  static void debug(String message) {
    _instance._logger.d(message);
  }

  static void info(String message) {
    _instance._logger.i(message);
  }

  static void warning(String message) {
    _instance._logger.w(message);
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

  static void fatal(String message) {
    _instance._logger.f(message);
  }
}
