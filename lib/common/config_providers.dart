import 'package:asmr_downloader/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final configFileProvider = Provider<JsonStorage>((ref) {
  return JsonStorage(filePath: 'asmr_dl_config.json');
});

final downloadPathProvider = StateProvider<String>((ref) => '');

final dlCoverProvider = StateProvider<bool>((ref) => false);

final clashProxyProvider = StateProvider<String>((ref) => 'DIRECT');

final apiChannelProvider = StateProvider<String>((ref) => 'asmr-200');
