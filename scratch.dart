import 'dart:convert';
void main() {
  String p = '{"delayView":"1,0;2,00:00:15;3,0;4,00:00:05;5,00:00:08;6,0;7,00:00:00"}';
  try {
    var j = jsonDecode(p);
    print('SUCCESS: ' + j.values.first.toString());
  } catch (e) {
    print('FAIL: ' + e.toString());
  }
}
