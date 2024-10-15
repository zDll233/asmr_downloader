import 'package:asmr_downloader/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final configFileProvider = Provider<JsonStorage>((ref) {
  return JsonStorage(filePath: 'config.json');
});

final dlCoverProvider = StateProvider<bool>((ref) => true);

final clashProxyProvider = StateProvider<bool>((ref) => false);

final apiHostProvider = StateProvider<String>((ref) => 'asmr-200');
