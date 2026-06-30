
import 'package:flutter/cupertino.dart';

class AppConstants {
  static bool isPumpLive(int modelId) => {11, 13, 4, 6, 12, 30, 38}.contains(modelId);
  static bool isDoublePumpLive(int modelId) => modelId == 27;
  static bool isIrrigationLive(int modelId) => {1, 5}.contains(modelId);
  static bool isWlc(int modelId) => {45}.contains(modelId);

  static String sendWlcCommand(String payload){
    String actualPayload = payload;
    int sumOfAscii = 0;
    for (var ch in actualPayload.split('')) {
      sumOfAscii += ch.codeUnitAt(0);
    }
    int crc = sumOfAscii % 256;
    String finalPayload = '{$actualPayload,${crc.toString().padLeft(3, '0')}}';
    return finalPayload;
  }

  static bool crcMatch(String payload, String hwCrc){
    String actualPayload = payload;
    int sumOfAscii = 0;
    for (var ch in actualPayload.split('')) {
      sumOfAscii += ch.codeUnitAt(0);
    }
    int crc = sumOfAscii % 256;
    String calculatedCrc = crc.toString().padLeft(3, '0');
    debugPrint("calculatedCrc = $calculatedCrc | hwCrc = $hwCrc");
    return calculatedCrc == hwCrc;
  }
}