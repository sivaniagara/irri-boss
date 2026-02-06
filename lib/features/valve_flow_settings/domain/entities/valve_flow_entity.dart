class ValveFlowEntity {
  final int menuSettingId;
  final String menuItem;
  final String templateName;
  final String templateJson;
  final String smsFormat;
  final List<ValveFlowNodeEntity> nodes;
  final String flowPercent;
  final String flowDeviation;
  final String deviceId;

  ValveFlowEntity({
    required this.menuSettingId,
    required this.menuItem,
    required this.templateName,
    required this.templateJson,
    required this.smsFormat,
    required this.nodes,
    required this.deviceId,
    this.flowPercent = '',
    this.flowDeviation = '0',
  });

  ValveFlowEntity copyWith({
    List<ValveFlowNodeEntity>? nodes,
    String? flowPercent,
    String? flowDeviation,
    String? deviceId,
  }) {
    return ValveFlowEntity(
      menuSettingId: menuSettingId,
      menuItem: menuItem,
      templateName: templateName,
      templateJson: templateJson,
      smsFormat: smsFormat,
      nodes: nodes ?? this.nodes,
      flowPercent: flowPercent ?? this.flowPercent,
      flowDeviation: flowDeviation ?? this.flowDeviation,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

class ValveFlowNodeEntity {
  final String nodeName;
  final String nodeId;
  final String serialNo;
  final String nodeValue;
  final String qrCode;
  final String flowDeviation;

  ValveFlowNodeEntity({
    required this.nodeName,
    required this.nodeId,
    required this.serialNo,
    required this.nodeValue,
    required this.qrCode,
    required this.flowDeviation,
  });

  ValveFlowNodeEntity copyWith({
    String? nodeValue,
    String? flowDeviation,
    String? nodeName,
  }) {
    return ValveFlowNodeEntity(
      nodeName: nodeName ?? this.nodeName,
      nodeId: nodeId,
      serialNo: serialNo,
      nodeValue: nodeValue ?? this.nodeValue,
      qrCode: qrCode,
      flowDeviation: flowDeviation ?? this.flowDeviation,
    );
  }
}
