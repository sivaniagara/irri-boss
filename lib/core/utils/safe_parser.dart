class SafeParser {
  /// Safely extracts the numeric ID from a program name string (e.g., "program1" -> "1")
  static String getProgramId(String programName) {
    if (programName.isEmpty) return '0';
    // Remove "program" (case-insensitive) and return the rest
    String id = programName.toLowerCase().replaceAll('program', '').trim();
    return id.isEmpty ? '0' : id;
  }

  /// Parses double from string, removing any non-numeric characters except '.'
  static double parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    // Keep only digits and decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}
