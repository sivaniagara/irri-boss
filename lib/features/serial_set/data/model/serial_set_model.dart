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
    List<dynamic> nodesList = [];

    if (rawSendData is String && rawSendData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSendData);
        if (decoded is Map) {
          sendDataMap = Map<String, dynamic>.from(decoded);
          // Support 'nodeList' from your specific API
          if (decoded['nodeList'] is List) {
            nodesList = decoded['nodeList'];
          } else if (decoded['nodes'] is List) {
            nodesList = decoded['nodes'];
          }
        } else if (decoded is List) {
          nodesList = decoded;
        }
      } catch (_) {}
    } else if (rawSendData is Map) {
      sendDataMap = Map<String, dynamic>.from(rawSendData);
      if (sendDataMap['nodeList'] is List) {
        nodesList = sendDataMap['nodeList'];
      } else if (sendDataMap['nodes'] is List) {
        nodesList = sendDataMap['nodes'];
      }
    }

    // Support both 'lorakey' and 'loraKey'
    String loraKey = (sendDataMap['lorakey'] ?? sendDataMap['loraKey'] ?? '').toString();

    // Added explicit mapping to handle potential dynamic type issues
    var nodes = nodesList.map((e) {
      if (e is Map) {
        return SerialSetNodeModel.fromJson(Map<String, dynamic>.from(e));
      }
      return const SerialSetNodeModel(qrCode: '', serialNo: '', nodeId: '');
    }).where((node) => node.nodeId.isNotEmpty || node.qrCode.isNotEmpty).toList();

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
      // Added nodeName fallback as seen in your API response
      qrCode: (json['QRCode'] ?? json['qrCode'] ?? json['nodeName'] ?? '').toString(),
      serialNo: (json['serialNo'] ?? '').toString(),
      nodeId: (json['nodeId'] ?? '').toString(),
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
