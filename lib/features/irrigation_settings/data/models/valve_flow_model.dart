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
    // Safely handle sendData which contains the nodes
    var rawSendData = json['sendData'];
    List<dynamic> sendDataList = [];
    if (rawSendData is String) {
      try {
        sendDataList = jsonDecode(rawSendData);
      } catch (_) {
        sendDataList = [];
      }
    } else if (rawSendData is List) {
      sendDataList = rawSendData;
    }
    
    var nodes = sendDataList.map((e) {
      var node = ValveFlowNodeModel.fromJson(e);
      // Initialize nodeValue to 0 as requested, but keep its actual serialNo and ID
      return node.copyWith(nodeValue: '0', flowDeviation: '0');
    }).toList();

    // Safely handle templateJson for flowPercent
    var rawTemplateJson = json['templateJson'];
    Map<String, dynamic> templateJsonData = {};
    if (rawTemplateJson is String) {
      try {
        templateJsonData = jsonDecode(rawTemplateJson);
      } catch (_) {
        templateJsonData = {};
      }
    } else if (rawTemplateJson is Map) {
      templateJsonData = Map<String, dynamic>.from(rawTemplateJson);
    }

    // Safely handle smsFormat
    var smsFormatRaw = json['smsFormat'];
    String smsFormatStr = "";
    if (smsFormatRaw is Map) {
      smsFormatStr = jsonEncode(smsFormatRaw);
    } else {
      smsFormatStr = smsFormatRaw?.toString() ?? '';
    }

    return ValveFlowModel(
      menuSettingId: json['menuSettingId'] ?? 0,
      menuItem: json['menuItem'] ?? '',
      templateName: json['templateName'] ?? '',
      templateJson: rawTemplateJson is String ? rawTemplateJson : jsonEncode(rawTemplateJson ?? {}),
      smsFormat: smsFormatStr,
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
    print('json: $json');

    return ValveFlowNodeModel(
      nodeName: json['nodeName']?.toString() ?? '',
      nodeId: json['nodeId']?.toString() ?? '',
      // Map serialNo accurately from the API response
      serialNo: json['serialNo']?.toString() ?? '', 
      nodeValue: json['nodeValue']?.toString() ?? '0',
      qrCode: json['QRCode']?.toString() ?? '',
      flowDeviation: json['flowDeviation']?.toString() ?? '0',
    );

  }
}
