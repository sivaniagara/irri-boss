import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingTimePicker extends StatefulWidget {
  final String initialTime;
  final bool showSeconds;
  final ValueChanged<String> onTimeChanged;

  const SettingTimePicker({
    super.key,
    required this.initialTime,
    required this.showSeconds,
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

  void _updateTime(int type, int value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (type == 0) {
        currentTime = DateTime(2025, 1, 1, value, currentTime.minute, currentTime.second);
      } else if (type == 1) {
        currentTime = DateTime(2025, 1, 1, currentTime.hour, value, currentTime.second);
      } else {
        currentTime = DateTime(2025, 1, 1, currentTime.hour, currentTime.minute, value);
      }
    });
    widget.onTimeChanged(_formatTime());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Center(child: _buildHeader("HOURS"))),
            Expanded(child: Center(child: _buildHeader("MINUTES"))),
            if (widget.showSeconds)
              Expanded(child: Center(child: _buildHeader("SECONDS"))),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glassy selection highlight
              Container(
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.15), 
                    width: 1.5,
                  ),
                ),
              ),
              // Wheel Pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _AttractiveWheel(
                      maxCount: 24,
                      initialValue: currentTime.hour,
                      onChanged: (val) => _updateTime(0, val),
                    ),
                  ),
                  Expanded(
                    child: _AttractiveWheel(
                      maxCount: 60,
                      initialValue: currentTime.minute,
                      onChanged: (val) => _updateTime(1, val),
                    ),
                  ),
                  if (widget.showSeconds)
                    Expanded(
                      child: _AttractiveWheel(
                        maxCount: 60,
                        initialValue: currentTime.second,
                        onChanged: (val) => _updateTime(2, val),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _AttractiveWheel extends StatefulWidget {
  final int maxCount;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _AttractiveWheel({
    required this.maxCount,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_AttractiveWheel> createState() => _AttractiveWheelState();
}

class _AttractiveWheelState extends State<_AttractiveWheel> {
  late FixedExtentScrollController _controller;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = FixedExtentScrollController(initialItem: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 54,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.005,
      squeeze: 1.1,
      overAndUnderCenterOpacity: 0.4,
      onSelectedItemChanged: (index) {
        final val = index % widget.maxCount;
        setState(() {
          _selectedValue = val;
        });
        widget.onChanged(val);
      },
      childDelegate: ListWheelChildLoopingListDelegate(
        children: List.generate(widget.maxCount, (index) {
          final isSelected = _selectedValue == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: isSelected ? 28 : 22,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500,
              ),
              child: Text(index.toString().padLeft(2, '0')),
            ),
          );
        }),
      ),
    );
  }
}