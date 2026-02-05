import 'dart:convert';
import '../../domain/entities/serial_set_entity.dart';

class SerialSetModel extends SerialSetEntity {
  const SerialSetModel({
    required super.menuSettingId,
    required super.menuItem,
    required super.nodes,
    required super.loraKey,
    required super.smsFormat,
  });

  factory SerialSetModel.fromJson(Map<String, dynamic> json) {
    var rawSendData = json['sendData'];
    Map<String, dynamic> sendDataMap = {};
    if (rawSendData is String && rawSendData.isNotEmpty) {
      try {
        sendDataMap = jsonDecode(rawSendData);
      } catch (_) {}
    } else if (rawSendData is Map) {
      sendDataMap = Map<String, dynamic>.from(rawSendData);
    }

    // In this specific API response, sendData contains loraKey as a single field
    // Nodes might be expected from a different part or format, but following your JSON:
    String loraKey = sendDataMap['loraKey']?.toString() ?? '';

    // If nodes are expected in sendData as a list (like in other modules):
    List<dynamic> nodesList = [];
    if (sendDataMap['nodes'] is List) {
      nodesList = sendDataMap['nodes'];
    }

    var nodes = nodesList.map((e) => SerialSetNodeModel.fromJson(e)).toList();

    return SerialSetModel(
      menuSettingId: json['menuSettingId'] ?? 481,
      menuItem: json['menuItem'] ?? 'COMMON SERIALSET',
      nodes: nodes,
      loraKey: loraKey,
      smsFormat: json['smsFormat']?.toString() ?? '',
    );
  }
}

class SerialSetNodeModel extends SerialSetNodeEntity {
  const SerialSetNodeModel({
    required super.qrCode,
    required super.serialNo,
    required super.nodeId,
  });

  factory SerialSetNodeModel.fromJson(Map<String, dynamic> json) {
    return SerialSetNodeModel(
      qrCode: json['QRCode']?.toString() ?? '',
      serialNo: json['serialNo']?.toString() ?? '',
      nodeId: json['nodeId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'QRCode': qrCode,
      'serialNo': serialNo,
      'nodeId': nodeId,
    };
  }
}
