import 'package:asmr_downloader/common/config_providers.dart';
import 'package:asmr_downloader/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsmrApiHost extends ConsumerWidget {
  const AsmrApiHost({super.key});

  static const List<String> _dropdownItems = [
    'asmr-100',
    'asmr-200',
    'asmr-300'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiHost = ref.watch(apiHostProvider);
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: DropdownButton<String>(
          value: apiHost,
          focusColor: Colors.transparent,
          items: _dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: ref.read(uiServiceProvider).onApiHostChoosed,
        ),
      ),
    );
  }
}
