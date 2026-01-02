
double timeStringToDouble(String time) {
  if (!time.contains(':')) return 0.0;

  final parts = time.split(':');
  final hours = double.tryParse(parts[0]) ?? 0;
  final minutes = double.tryParse(parts[1]) ?? 0;

  return hours + (minutes / 60);
}