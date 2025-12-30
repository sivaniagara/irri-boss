import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/standalone_entity.dart';
import '../bloc/standalone_bloc.dart';
import '../bloc/standalone_event.dart';

class ZoneItem extends StatelessWidget {
  final int index;
  final ZoneEntity zone;

  const ZoneItem({
    super.key,
    required this.index,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure time is in HH:mm format for display
    String displayTime = zone.time;
    if (displayTime.split(':').length > 2) {
      displayTime = displayTime.substring(0, 5); // Take only HH:mm
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              "ZONE ${zone.zoneNumber.padLeft(3, '0')}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _parseTime(zone.time),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  final String formattedTime = 
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                  context.read<StandaloneBloc>().add(UpdateZoneTime(index, formattedTime));
                }
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(
                  displayTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _PillToggle(
            value: zone.status,
            onChanged: (v) {
              context.read<StandaloneBloc>().add(ToggleZone(index, v));
            },
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

class _PillToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 70,
        height: 32,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF2E7D32) : Colors.redAccent[400],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Align(
                alignment: value ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(left: value ? 8.0 : 0, right: value ? 0 : 8.0),
                  child: Text(
                    value ? "ON" : "OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
