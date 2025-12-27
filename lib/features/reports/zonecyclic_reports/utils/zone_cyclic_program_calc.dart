

 
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/domain/entities/zone_cyclic_entities.dart';

class ZoneCyclicProgramCalculator {
  // ---------------- PROGRAM TOTAL FLOW ----------------
  static double programTotalFlow(ZoneProgramEntity program) {
    double total = 0;

    for (final zone in program.zoneList) {
      total += double.tryParse(zone.flow) ?? 0;
    }

    return total;
  }

  // ---------------- PROGRAM TOTAL DURATION ----------------
  static String programTotalDuration(ZoneProgramEntity program) {
    int totalSeconds = 0;

    for (final zone in program.zoneList) {
      totalSeconds += _durationToSeconds(zone.duration);
    }

    return _secondsToDuration(totalSeconds);
  }

  // ---------------- HELPERS ----------------
  static int _durationToSeconds(String duration) {
    final parts = duration.split(':');
    if (parts.length != 3) return 0;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;

    return (h * 3600) + (m * 60) + s;
  }

  static String _secondsToDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}
