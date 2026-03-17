String getSmsSync(String message) {
  if (message.isEmpty || message.toUpperCase() == "NA") return "";

  try {
    // Robust parsing using RegExp to handle varying spaces
    final dateMatch = RegExp(r"DATE=([0-9/,-]+)").firstMatch(message);
    final timeMatch = RegExp(r"TIME=([0-9:]+)").firstMatch(message);

    if (dateMatch != null && timeMatch != null) {
      final date = dateMatch.group(1) ?? "";
      final time = timeMatch.group(1) ?? "";
      return "$time\n$date";
    }
  } catch (e) {
    // Fallback to old method if regex fails
  }

  // Fallback for older formats or if regex missed
  if (!message.contains("DATE=") || !message.contains("TIME=")) {
    return "";
  }

  try {
    final date = message.split("DATE=")[1].split(" ")[0].trim();
    final time = message.split("TIME=")[1].split(" ")[0].trim();
    return "$time\n$date";
  } catch (e) {
    return "";
  }
}

String getDisplayMessage(String message) {
  if (message.isEmpty || message.toUpperCase() == "NA") return "";

  final trimmed = message.trim();
  final parts = trimmed.split(',');
  int lIndex = parts.indexOf('\$L');
  if (lIndex != -1) {
    if (parts.length > lIndex + 2) {
      return "${parts[lIndex + 1]} ${parts[lIndex + 2]}".trim();
    }
  }

  // Handle LD01: format but be careful not to strip legitimate colons in key-value messages
  if (RegExp(r'^[A-Z0-9]{4}:').hasMatch(trimmed)) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  }

  return trimmed;
}

String getMsgCode(String message) {
  if (message.isEmpty) return "";
  final parts = message.trim().split(',');
  int lIndex = parts.indexOf('\$L');
  if (lIndex != -1 && parts.length > lIndex + 14) {
    return parts[lIndex + 14].trim();
  }

  // Fallback to legacy formats
  String trimmed = message.trim();
  if (trimmed.contains(':')) {
    String after = trimmed.substring(trimmed.indexOf(':') + 1).trim();
    return after.length >= 3 ? after.substring(0, 3) : after;
  }

  return trimmed.length >= 3 ? trimmed.substring(0, 3) : trimmed;
}

String getSTIM(String message) {
  if (message.contains("FLO=")) {
    try {
      final part = message.split("FLO=")[1];
      return part.split(" ").first.trim();
    } catch (e) {}
  }
  if (message.contains("setFlow")) {
    try {
      final part = message.split("setFlow")[1];
      return part.split(" ").first.split(",").first.trim();
    } catch (e) {}
  }

  if (!message.contains("STIM=")) return "";
  try {
    final part = message.split("STIM=")[1];
    return part.split(" ").first.trim();
  } catch (e) {
    return "";
  }
}

String getRTIM(String message) {
  if (message.contains("RFLO=")) {
    try {
      final part = message.split("RFLO=")[1];
      return part.split(" ").first.trim();
    } catch (e) {}
  }
  if (message.contains("remFlow")) {
    try {
      final part = message.split("remFlow")[1];
      return part.split(" ").first.split(",").first.trim();
    } catch (e) {}
  }

  if (!message.contains("RTIM=")) return "";
  try {
    final part = message.split("RTIM=")[1];
    return part.split(" ").first.trim();
  } catch (e) {
    return "";
  }
}
