import 'package:asmr_downloader/asmr_repo/asmr_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final asmrApiProvider = Provider<AsmrApi>((ref) {
  return AsmrApi(
    name: 'moondasscry',
    password: 'lzd951413',
    proxy: '127.0.0.1:7890',
  );
});


