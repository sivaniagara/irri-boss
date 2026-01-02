import 'package:flutter/material.dart';

class NodeStatusImages {
  static const Map<String, String> _categoryIcons = {
    'lights': "assets/svg/node_status_svg/bulb_m.svg",
    'flowmeter': "assets/svg/node_status_svg/flow_meter_m.svg",
    'energymeter': "assets/svg/node_status_svg/energy_meter_m.svg",
    'fertilizer': "assets/svg/node_status_svg/fert_m.svg",
    'pressure': "assets/svg/node_status_svg/pressure_m.svg",
    'moisture': "assets/svg/node_status_svg/moisture_sensor_m.svg",
    'valves': "assets/svg/node_status_svg/valve_m.svg",
  };

  static const Map<String, Color> _statusColors = {
    '0': Colors.grey,
    '1': Colors.green,
    '2': Colors.red,
    '3': Colors.orange,
    '4': Colors.grey,
    '10': Colors.amber,
  };

  static String getIcon(String category) {
    final normalized = category.toLowerCase().replaceAll(' ', '');

    if (normalized.contains('valve')) return _categoryIcons['valves']!;
    if (normalized.contains('light')) return _categoryIcons['lights']!;
    if (normalized.contains('flowmeter')) return _categoryIcons['flowmeter']!;
    if (normalized.contains('energy')) return _categoryIcons['energymeter']!;
    if (normalized.contains('fertilizer')) return _categoryIcons['fertilizer']!;
    if (normalized.contains('pressure')) return _categoryIcons['pressure']!;
    if (normalized.contains('moisture')) return _categoryIcons['moisture']!;

    return _categoryIcons['valves']!;
  }

  static Color getTintColor(String status) {
    return _statusColors[status] ?? Colors.grey;
  }
}