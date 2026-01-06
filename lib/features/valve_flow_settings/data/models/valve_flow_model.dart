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
    super.flowPercent,
    super.flowDeviation,
  });

  factory ValveFlowModel.fromJson(Map<String, dynamic> json) {
    var rawSendData = json['sendData'];
    List<dynamic> sendDataList = [];
    if (rawSendData is String) {
      try {
        sendDataList = jsonDecode(rawSendData);
      } catch (_) {}
    } else if (rawSendData is List) {
      sendDataList = rawSendData;
    }
    
    var nodes = sendDataList.map((e) => ValveFlowNodeModel.fromJson(e)).toList();

    var rawTemplateJson = json['templateJson'];
    Map<String, dynamic> templateJsonData = {};
    if (rawTemplateJson is String) {
      try {
        templateJsonData = jsonDecode(rawTemplateJson);
      } catch (_) {}
    } else if (rawTemplateJson is Map) {
      templateJsonData = Map<String, dynamic>.from(rawTemplateJson);
    }

    return ValveFlowModel(
      menuSettingId: json['menuSettingId'] ?? 0,
      menuItem: json['menuItem'] ?? '',
      templateName: json['templateName'] ?? '',
      templateJson: rawTemplateJson is String ? rawTemplateJson : jsonEncode(rawTemplateJson ?? {}),
      smsFormat: json['smsFormat']?.toString() ?? '',
      nodes: nodes,
      flowPercent: templateJsonData['FLOWPERCENT']?.toString() ?? '',
      flowDeviation: '0', 
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
    return ValveFlowNodeModel(
      nodeName: json['nodeName']?.toString() ?? '',
      nodeId: json['nodeId']?.toString() ?? '',
      serialNo: json['serialNo']?.toString() ?? '',
      nodeValue: '0', // Initial value as requested
      qrCode: json['QRCode']?.toString() ?? '',
      flowDeviation: '0', // Initial value as requested
    );
  }
}
