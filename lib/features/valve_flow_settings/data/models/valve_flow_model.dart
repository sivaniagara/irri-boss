import 'dart:convert';
import '../../domain/entities/valve_flow_entity.dart';

class ValveFlowModel extends ValveFlowEntity {
  ValveFlowModel({
    required super.menuSettingId,
    required super.menuItem,
    required super.templateName,
    required super.templateJson,
    required super.smsFormat,
    required super.nodes,
    required super.deviceId,
    super.flowPercent,
    super.flowDeviation,
  });

  factory ValveFlowModel.fromJson(Map<String, dynamic> json) {
    var rawSendData = json['sendData'];
    List<dynamic> sendDataList = [];

    if (rawSendData != null) {
      if (rawSendData is String) {
        try {
          final decoded = jsonDecode(rawSendData);
          if (decoded is List) {
            sendDataList = decoded;
          } else if (decoded is Map && decoded.containsKey('setting')) {
            sendDataList = decoded['setting'] as List;
          }
        } catch (_) {}
      } else if (rawSendData is List) {
        sendDataList = rawSendData;
      } else if (rawSendData is Map && rawSendData.containsKey('setting')) {
        sendDataList = rawSendData['setting'] as List;
      }
    }

    var nodes = sendDataList.map((e) => ValveFlowNodeModel.fromJson(e)).toList();

    var rawTemplateJson = json['templateJson'];
    Map<String, dynamic> templateJsonData = {};
    if (rawTemplateJson != null) {
      if (rawTemplateJson is String) {
        try {
          templateJsonData = jsonDecode(rawTemplateJson);
        } catch (_) {}
      } else if (rawTemplateJson is Map) {
        templateJsonData = Map<String, dynamic>.from(rawTemplateJson);
      }
    }

    return ValveFlowModel(
      menuSettingId: json['menuSettingId'] ?? 0,
      menuItem: json['menuItem'] ?? '',
      templateName: json['templateName'] ?? '',
      templateJson: rawTemplateJson is String ? rawTemplateJson : jsonEncode(rawTemplateJson ?? {}),
      smsFormat: json['smsFormat']?.toString() ?? '',
      nodes: nodes,
      flowPercent: templateJsonData['FLOWPERCENT']?.toString() ?? '',
<<<<<<< HEAD
      flowDeviation: templateJsonData['FLOWPERCENT']?.toString() ?? '0',
      deviceId: '', // Will be populated by copyWith in Bloc
=======
<<<<<<< HEAD
      flowDeviation: templateJsonData['FLOWPERCENT']?.toString() ?? '0', 
=======
      flowDeviation: '0', 
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
    );
  }
}

class ValveFlowNodeModel extends ValveFlowNodeEntity {
  ValveFlowNodeModel({
    required super.nodeName,
    required super.nodeId,
    required super.serialNo,
    required super.nodeValue,
    required super.qrCode,
    required super.flowDeviation,
  });

  factory ValveFlowNodeModel.fromJson(Map<String, dynamic> json) {
    // Handling the case where the values might be under different keys or types
    return ValveFlowNodeModel(
      nodeName: json['nodeName']?.toString() ?? '',
<<<<<<< HEAD
      nodeId: (json['nodeId'] ?? json['SN'] ?? '').toString(),
      serialNo: (json['serialNo'] ?? json['SF'] ?? '').toString(),
      nodeValue: (json['nodeValue'] ?? json['VAL'] ?? '0').toString(),
      qrCode: (json['QRCode'] ?? json['HF'] ?? '').toString(),
      flowDeviation: (json['flowDeviation'] ?? '0').toString(),
=======
      nodeId: json['nodeId']?.toString() ?? '',
      serialNo: json['serialNo']?.toString() ?? '',
<<<<<<< HEAD
      nodeValue: json['nodeValue']?.toString() ?? '0',
      qrCode: json['QRCode']?.toString() ?? '',
      flowDeviation: json['flowDeviation']?.toString() ?? '0',
=======
      nodeValue: '0', // Initial value as requested
      qrCode: json['QRCode']?.toString() ?? '',
      flowDeviation: '0', // Initial value as requested
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
    );
  }
}
