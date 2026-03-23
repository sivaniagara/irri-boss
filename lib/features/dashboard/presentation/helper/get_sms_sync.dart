import 'package:intl/intl.dart';

class FaultSms {
  static String smsMessage(String smsCode) {
    switch (smsCode) {
      case "000":
        return "";

      case "001":
        return "MOTOR ON  3 PHASE";

      case "002":
        return "MOTOR ON  2 PHASE";

      case "003":
        return "MOTOR OFF";

      case "004":
      case "005":
        return "MOTOR ON BECAUSE OF CYCLIC ON TIME";

      case "006":
      case "007":
        return "MOTOR ON BECAUSE OF AUTO MOBILE SWITCH";

      case "008":
      case "009":
        return "MOTOR ON BECAUSE OF GREEN RTC";

      case "010":
      case "011":
        return "MOTOR ON BECAUSE OF RTC ON TIME";

      case "012":
      case "013":
        return "MOTOR ON BECAUSE OF UPPER TANK EMPTY";

      case "014":
      case "015":
        return "MOTOR ON BECAUSE OF SUMP TANK FULL";

      case "016":
      case "017":
        return "MOTOR ON BECAUSE OF RESTART TIMER";

      case "018":
      case "019":
        return "MOTOR ON BECAUSE OF TARGET";

      case "020":
        return "MOTOR OFF  3 PHASE";

      case "021":
        return "MOTOR OFF  2 PHASE";

      case "022":
        return "MOTOR OFF BECAUSE OF UPPER TANK FULL";

      case "023":
        return "MOTOR OFF BECAUSE OF LOWER TANK EMPTY";

      case "024":
        return "MOTOR OF BECAUSE OF MOBILE AUTO SWITCH";

      case "025":
      case "026":
        return "MOTOR OFF BECAUSE OF DRY RUN";

      case "027":
        return "MOTOR OFF BECAUSE OF CYCLIC TRIP";

      case "028":
        return "MOTOR OFF BECAUSE OF ZONE CYCLLE COMPLETED";

      case "029":
        return "MOTOR OFF BECAUSE OF GRTC PROGRAM TIME REACHED";

      case "030":
        return "MOTOR OFF BECAUSE OF RTC PROGRAM";

      case "031":
        return "POWER ON WITH 3 PHASE, AUTO RESTART ON";

      case "032":
        return "AUTO RESTART OFF";

      case "033":
        return "POWER ON WITH 3 PHASE";

      case "034":
        return "POWER ON WITH 2 PHASE, AUTO RESTART ON";

      case "035":
        return "POWER ON WITH 2 PHASE, AUTO RESTART OFF";

      case "036":
        return "POWER ON WITH 2 PHASE";

      case "037":
      case "038":
      case "039":
        return "POWER OFF";

      case "040":
        return "MOTOR OFF 3 PHASE";

      case "041":
        return "MOTOR OFF 2 PHASE";

      case "042":
        return "MOTOR OFF POWER ON";

      case "043":
        return "MOTOR OFF POWER OF";

      case "044":
      case "045":
        return "ZONE OPEN";

      case "046":
        return "FERTILIZER PUMP";

      case "047":
        return "NIGHT LIGHT ON";

      case "048":
      case "049":
        return "NIGHT LIGHT OFF";

      case "050":
        return "GREEN LIGHT OFF";

      case "051":
        return "GREEN LIGHT ON BECAUSE OF CYCLIC TIMER";

      case "052":
        return "GREEN LIGHT OFF BECAUSE OF CYCLIC TIMER";

      case "053":
        return "GREEN FAN ON BECAUSE OF RTC";

      case "054":
        return "GREEN FAN OFF BECAUSE OF RTC";

      case "055":
        return "GREEN FAN ON BECAUSE OF CYCLIC TIMER";

      case "056":
        return "GREEN FAN OFF BECAUSE OF CYCLIC TIMER";

      case "057":
        return "GREEN FOG ON BECAUSE OF RTC,DT";

      case "058":
        return "GREEN FOG OFF BECAUSE OF RTC,DT";

      case "059":
      case "060":
        return "GREEN FOG VALVE";

      case "061":
        return "GREEN FOG CYCLE COMPLETED";

      case "062":
        return "GREEN FOG CYCLE RESET BACAUSE OF CYCLIC TIMER";

      case "063":
      case "064":
        return "STANDALONE ZONE :";

      case "065":
        return "MOTOR OFF BECAUSE OF STARTER TRIP MOTOR STARTED WITH 3 PHASE";

      case "066":
        return "MOTOR CAN'T START";

      case "067":
        return "MOTOR OFF BECAUSE OF PRESSURE SWITCH OPEN";

      case "068":
        return "MOTOR OFF BECAUSE OF MAXIMUM RUN TIME REACHED";

      case "070":
        return "MOTOR 2 ON";

      case "071":
        return "MOTOR 2 OFF";

      case "101":
      case "102":
        return "MOTOR OFF BECAUSE OF STARTER TRIP";

      case "105":
      case "106":
        return "MOTOR OFF BECAUSE OF OVER LOAD";

      case "107":
        return "MOTOR OFF BECAUSE OF SINGLE PHASEING";

      case "108":
        return "MOTOR OFF BECAUSE OF REVERSE PHASEING";

      case "110":
      case "111":
        return "MOTOR OFF BECAUSE OF LOW VOLTAGE";

      case "112":
      case "113":
        return "MOTOR OFF BECAUSE OF HIGH VOLTAGE";

      case "114":
        return "ZONE SKIPPED BECAUSE OF NO FEEDBACK";

      case "116":
      case "117":
        return "MOTOR OFF BECAUSE OF DRY RUN";

      case "119":
      case "120":
        return "MOTOR OFF BECAUSE OF HIPRESSURE";

      case "139":
        return "ZONE NOT OPEN PROPERLY";

      case "140":
        return "ZONE NOT CLOSED PROPERLY";

      default:
        return "SETTINGS MSG";
    }
  }
}

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
  
  // Try to find $L format
  final parts = trimmed.split(',');
  int lIndex = parts.indexOf('\$L');
  if (lIndex != -1) {
    if (parts.length > lIndex + 2) {
      return "${parts[lIndex + 1]} ${parts[lIndex + 2]}".trim();
    }
  }

  // Handle LD01: or LD04, format by stripping the prefix
  if (RegExp(r'^[A-Z0-9]{4}[:]').hasMatch(trimmed)) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  } else if (RegExp(r'^[A-Z0-9]{4}[,]').hasMatch(trimmed)) {
    return trimmed.substring(trimmed.indexOf(',') + 1).trim();
  }

  return trimmed;
}

String getMsgCode(String message) {
  if (message.isEmpty) return "";
  String trimmed = message.trim();
  
  // Try to find the code in format like -001/080 or -068/080
  final match = RegExp(r'-(\d{3})').firstMatch(trimmed);
  if (match != null) {
    return match.group(1)!;
  }

  // Handle prefixes like LD01: or LD04,
  String content = trimmed;
  if (content.contains(':')) {
    content = content.substring(content.indexOf(':') + 1).trim();
  } else if (RegExp(r'^[A-Z0-9]{4},').hasMatch(content)) {
    content = content.substring(content.indexOf(',') + 1).trim();
  }

  final parts = content.split(',');
  
  // New style message with $L
  int lIndex = parts.indexOf('\$L');
  if (lIndex != -1 && parts.length > lIndex + 14) {
    return parts[lIndex + 14].trim();
  }

  // If we have parts, the first part is often the code
  if (parts.isNotEmpty) {
    String firstPart = parts[0].trim();
    // If it's a numeric code (even if 1 or 2 digits), it's likely a status code
    if (RegExp(r'^\d+$').hasMatch(firstPart)) {
      return firstPart.padLeft(3, '0');
    }
  }

  return "";
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
