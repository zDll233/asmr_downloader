import 'package:asmr_downloader/services/asmr_repo/asmr_api.dart';
import 'package:asmr_downloader/utils/log.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void printFormattedMap(Map<String, dynamic> map) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 设置缩进为两个空格
  String prettyPrint = encoder.convert(map);
  if (kDebugMode) {
    print(prettyPrint);
  }
}

void main() {
  late final AsmrApi api;

  setUpAll(() async {
    Log.debug('set up');
    api = AsmrApi();

    // await asmrApi.login();
  });

  group('AsmrAPI', () {
    test('get playlist', () async {
      final playlist = await api.getPlaylists(page: 1);
      printFormattedMap(playlist!);
    });

    // getSearchResult
    test('get search results', () async {
      final searchResults = await api.search(
        content: '柚木',
        params: {
          'page': 1,
          'pageSize': 12,
          'filterBy': 'all',
        },
      );
      printFormattedMap(searchResults!);
    });

    // getWorkInfo
    test('get work info', () async {
      final workInfo = await api.getWorkInfo(id: '422979');
      printFormattedMap(workInfo!);
    });

    // getVoiceTracks
    test('get voice tracks', () async {
      final voiceTracks = await api.getTracks(id: '422979');
      for (var voiceTrack in voiceTracks!) {
        printFormattedMap(voiceTrack);
      }
    });
  });
}
