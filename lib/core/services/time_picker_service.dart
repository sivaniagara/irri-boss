import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';

import '../../features/pump_settings/presentation/widgets/setting_time_picker.dart';
import '../widgets/alert_dialog.dart';

class TimePickerService {
  static Future<String?> show({
    required BuildContext context,
    required String initialTime,
    String title = "Select Time"
  }) async {
    String? selectedTime = initialTime;
    String? temp = initialTime;

    await GlassyAlertDialog.show(
      context: context,
      title: title,
      content: _TimePickerContent(
        initialTime: initialTime,
        showSeconds: initialTime.split(":").length > 2,
        onTimeChanged: (newTime) {
          temp = newTime;
        },
      ),
      actions: [
        ActionButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ActionButton(
          onPressed: () {
            selectedTime = temp;
            Navigator.pop(context, temp);
          },
          isPrimary: true,
          child: const Text("Done"),
        ),
      ],
    );

    return selectedTime;
  }
}

// Private content widget — keeps dialog clean
class _TimePickerContent extends StatelessWidget {
  final String initialTime;
  final bool showSeconds;
  final ValueChanged<String> onTimeChanged;

  const _TimePickerContent({
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