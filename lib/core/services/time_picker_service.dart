import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';

import '../../features/pump_settings/presentation/widgets/setting_time_picker.dart';
import '../widgets/alert_dialog.dart';

class TimePickerService {
  static Future<String?> show({
    required BuildContext context,
    required String initialTime,
    String title = "Select Time",
  }) {
    String? temp = initialTime;

    return GlassyAlertDialog.show<String>(
      context: context,
      title: title,
      content: _TimePickerContent(
        initialTime: initialTime,
        showSeconds: initialTime.split(":").length > 2,
        onTimeChanged: (newTime) {
          temp = newTime;
        },
      ),
      actionsBuilder: (dialogContext) => [
        ActionButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Cancel"),
        ),
        ActionButton(
          onPressed: () => Navigator.pop(dialogContext, temp),
          isPrimary: true,
          child: const Text("Done"),
        ),
      ],
    );
  }
}

// Private content widget — keeps dialog clean
class _TimePickerContent extends StatelessWidget {
  final String initialTime;
  final bool showSeconds;
  final ValueChanged<String> onTimeChanged;

  _TimePickerContent({
    required this.initialTime,
    required this.showSeconds,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SettingTimePicker(
        initialTime: initialTime,
        onTimeChanged: onTimeChanged,
        showSeconds: showSeconds,
      ),
    );
  }
}
