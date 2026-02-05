import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
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
    String displayTime = zone.time;
    if (displayTime.split(':').length > 2) {
      displayTime = displayTime.substring(0, 5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ZONE ${zone.zoneNumber.padLeft(3, '0')}",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Irrigation Zone",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _parseTime(zone.time),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      ),
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
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ),
                child: Text(
                  displayTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CustomSwitch(
            value: zone.status,
            onChanged: (v) {
              context.read<StandaloneBloc>().add(ToggleZone(index, v as bool));
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
