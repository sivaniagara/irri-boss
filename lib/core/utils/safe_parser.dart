class SafeParser {
  /// Safely extracts the numeric ID from a program name string.
  static String getProgramId(String programName) {
    if (programName.isEmpty) return '0';

    final match = RegExp(r'\d+').firstMatch(programName);
    return match?.group(0) ?? '0';
  }

  /// Parses double from string, removing any non-numeric characters except '.'
  static double parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    // Keep only digits and decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}
