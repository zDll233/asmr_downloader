import 'package:asmr_downloader/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double titleBarHeight = 50.0;

final configProvider = Provider<JsonStorage>((ref) {
  return JsonStorage(filePath: 'config.json');
});