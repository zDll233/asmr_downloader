import 'dart:io';
import 'dart:convert';

import 'package:asmr_downloader/utils/log.dart';

class JsonStorage {
  final String filePath;

  JsonStorage({required this.filePath});

  Future<Map<String, dynamic>> read() async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      Log.error('read "$filePath" failed\n' 'error: $e');
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> data) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final contents = json.encode(data);
    await file.writeAsString(contents);
  }

  Future<void> addOrUpdate(Map<String, dynamic> data) async {
    final currentData = await read();
    currentData.addAll(data);
    await write(currentData);
  }
}
