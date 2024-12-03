import 'package:asmr_downloader/services/asmr_repo/asmr_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final asmrApiProvider = Provider<AsmrApi>((ref) => AsmrApi());
