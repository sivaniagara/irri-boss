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
