import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class SettingTimePicker extends StatefulWidget {
  final String initialTime;
  final bool showSeconds;
  final ValueChanged<String> onTimeChanged;

  const SettingTimePicker({
    super.key,
    required this.initialTime,
    this.showSeconds = true,
    required this.onTimeChanged,
  });

  @override
  State<SettingTimePicker> createState() => _SettingTimePickerState();
}

class _SettingTimePickerState extends State<SettingTimePicker> {
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = _parseTime(widget.initialTime);
  }

  DateTime _parseTime(String s) {
    final parts = s.trim().split(':');
    final hour = int.tryParse(parts[0].padLeft(2, '0'))?.clamp(0, 23) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1])?.clamp(0, 59) ?? 0) : 0;
    final second = parts.length > 2 ? (int.tryParse(parts[2])?.clamp(0, 59) ?? 0) : 0;
    return DateTime(2025, 1, 1, hour, minute, second);
  }

  String _formatTime() {
    final h = currentTime.hour.toString().padLeft(2, '0');
    final m = currentTime.minute.toString().padLeft(2, '0');
    if (!widget.showSeconds) return '$h:$m';
    final s = currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: TimePickerSpinner(
            time: currentTime,
            is24HourMode: true,
            alignment: Alignment.center,
            spacing: 60,
            itemHeight: 80,
            isForce2Digits: true,
            normalTextStyle: const TextStyle(fontSize: 28, color: Colors.grey),
            highlightedTextStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            onTimeChange: (newTime) {
              setState(() => currentTime = newTime);
              widget.onTimeChanged(_formatTime());
            },
            isShowSeconds: widget.showSeconds,
          ),
        ),
      ],
    );
  }
}