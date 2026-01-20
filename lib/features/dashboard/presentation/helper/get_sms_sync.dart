String getSmsSync(String message) {
  if (!message.contains("DATE=") || !message.contains("TIME=")) {
    return "";
  }

  try {
    final date = message.split("DATE=")[1].split("  ")[0];
    final time = message.split("TIME=")[1].split(" ")[0];

    return "$time\n$date"; // 14:05:29-28/02/2023
  } catch (e) {
    return "";
  }
}