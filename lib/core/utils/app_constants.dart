
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static bool isPumpLive(int modelId) => {11, 13, 4, 6, 12, 30, 38}.contains(modelId);
  static bool isDoublePumpLive(int modelId) => modelId == 27;
  static bool isIrrigationLive(int modelId) => {1, 5}.contains(modelId);
  static bool isWlc(int modelId) => {45}.contains(modelId);

  static String sendWlcCommand(String payload) {
    String actualPayload = payload;

    // --- CRC-16 (Modbus) calculation ---
    List<int> bytes = actualPayload.codeUnits;
    int crc = 0xFFFF;

    for (int byte in bytes) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc = crc >> 1;
        }
      }
    }

    int crcLow = crc & 0xFF;
    int crcHigh = (crc >> 8) & 0xFF;

    // Format as 4-digit hex string
    String crcHex =
        crcHigh.toRadixString(16).padLeft(2, '0') +
            crcLow.toRadixString(16).padLeft(2, '0');

    // --- Keep your original output format ---
    String finalPayload = '{$actualPayload,$crcHex}';

    if (kDebugMode) {
      print('CRC16: $crcHex');
      print('Payload: $finalPayload');
    }

    return finalPayload;
  }

  static bool crcMatch(String payload, String hwCrc) {
    // Compute CRC-16 (Modbus) for payload
    List<int> bytes = payload.codeUnits;
    int crc = 0xFFFF;

    for (int byte in bytes) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc = crc >> 1;
        }
      }
    }

    // Extract high and low bytes
    int crcLow = crc & 0xFF;
    int crcHigh = (crc >> 8) & 0xFF;

    // Format as hex string (same as your validatePayloadWithCrc)
    String calculatedCrcHex =
        crcHigh.toRadixString(16).padLeft(2, '0') +
            crcLow.toRadixString(16).padLeft(2, '0');

    debugPrint("calculatedCrc = $calculatedCrcHex | hwCrc = $hwCrc");

    // Compare case-insensitively
    return calculatedCrcHex.toLowerCase() == hwCrc.toLowerCase();
  }

}