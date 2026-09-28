import 'dart:convert';

class ViewPayloadParser {
  static Map<int, String>? parseIndexed(String message) {
    var payload = message.trim();
    if (payload.contains('|')) {
      payload = payload.split('|').first.trim();
    }

    bool wrapped = false;

    // 1. Unwrap { "key": "value" }
    final start = payload.indexOf('{');
    final end = payload.lastIndexOf('}');
    if (start != -1 && end > start) {
      final inner = payload.substring(start, end + 1);
      try {
        final obj = jsonDecode(inner);
        if (obj is Map && obj.isNotEmpty) {
          payload = obj.values.first.toString();
          wrapped = true;
        }
      } catch (_) {
        // Map.toString() style -> {delayView: 1,0;2,...}
        final colon = inner.indexOf(':');
        if (colon != -1) {
          payload = inner.substring(colon + 1, inner.length - 1).trim();
          wrapped = true;
        }
      }
    }

    payload = payload.replaceAll('"', '').trim();

    // 2. Strip a leading ALPHABETIC command name only (e.g. "DELAYVIEW,").
    //    Never strip "1," — that is the first setting's value.
    payload = payload.replaceFirst(RegExp(r'^[A-Za-z_]+\s*,\s*'), '');

    if (!wrapped && !payload.contains(';')) return null;

    // 3. Split into index,value pairs
    final pairRe = RegExp(r'^\s*(\d+)\s*,(.*)$', dotAll: true);
    final map = <int, String>{};
    for (final pair in payload.split(';')) {
      final m = pairRe.firstMatch(pair);
      if (m == null) continue;
      map[int.parse(m.group(1)!)] = m.group(2)!.trim();
    }
    return map.isEmpty ? null : map;
  }
}