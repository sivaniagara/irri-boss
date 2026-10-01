import 'dart:convert';
void main() {
  String wlcPayload = '{"delayView":"1,0;2,00:00:04;3,00:00:05;4,00:00:06;5,00:00:00"}|C89B';
  bool isWlcFormat = false;
  if (wlcPayload.contains('|')) { wlcPayload = wlcPayload.split('|').first.trim(); }
  int startIdx = wlcPayload.indexOf('{');
  int endIdx = wlcPayload.lastIndexOf('}');
  if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
    try {
      String jsonStr = wlcPayload.substring(startIdx, endIdx + 1);
      final Map<String, dynamic> jsonObj = jsonDecode(jsonStr);
      if (jsonObj.isNotEmpty) { wlcPayload = jsonObj.values.first.toString(); isWlcFormat = true; }
    } catch (e) { print('JSON ERROR: ' + e.toString()); }
  }
  if (!isWlcFormat) {
    final firstComma = wlcPayload.indexOf(',');
    if (firstComma != -1 && wlcPayload.contains(';')) { wlcPayload = wlcPayload.substring(firstComma + 1).trim(); isWlcFormat = true; }
  }
  print('isWlcFormat: ' + isWlcFormat.toString());
  print('wlcPayload: ' + wlcPayload);
  Map<int, String> wlcValues = {};
  if (isWlcFormat && wlcPayload.contains(';')) {
    for (var pair in wlcPayload.split(';')) {
      final kv = pair.split(',');
      if (kv.length >= 2) {
        final idx = int.tryParse(kv[0].trim());
        if (idx != null) { wlcValues[idx] = kv.sublist(1).join(',').trim(); }
      }
    }
  }
  print('wlcValues: ' + wlcValues.toString());
}
