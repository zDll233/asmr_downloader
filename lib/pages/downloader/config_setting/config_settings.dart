import 'package:asmr_downloader/pages/downloader/config_setting/components/asmr_api_channel.dart';
import 'package:asmr_downloader/pages/downloader/config_setting/components/clash_proxy.dart';
import 'package:asmr_downloader/pages/downloader/config_setting/components/dl_cover_check.dart';
import 'package:asmr_downloader/pages/downloader/config_setting/components/dl_path_picker.dart';
import 'package:flutter/widgets.dart';

class ConfigSettings extends StatelessWidget {
  const ConfigSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DownloadPathPicker(),
        DlCoverCheck(),
        ClashProxy(),
        AsmrApiChannel(),
      ],
    );
  }
}