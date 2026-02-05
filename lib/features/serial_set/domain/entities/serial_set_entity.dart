import 'package:equatable/equatable.dart';

class SerialSetEntity extends Equatable {
  final int menuSettingId;
  final String menuItem;
  final List<SerialSetNodeEntity> nodes;
  final String loraKey;
  final String smsFormat;

  const SerialSetEntity({
    required this.menuSettingId,
    required this.menuItem,
    required this.nodes,
    required this.loraKey,
    required this.smsFormat,
  });

  @override
  List<Object?> get props => [menuSettingId, menuItem, nodes, loraKey, smsFormat];

  SerialSetEntity copyWith({
    List<SerialSetNodeEntity>? nodes,
    String? loraKey,
    String? smsFormat,
  }) {
    return SerialSetEntity(
      menuSettingId: menuSettingId,
      menuItem: menuItem,
      nodes: nodes ?? this.nodes,
      loraKey: loraKey ?? this.loraKey,
      smsFormat: smsFormat ?? this.smsFormat,
    );
  }
}

class SerialSetNodeEntity extends Equatable {
  final String qrCode;
  final String serialNo;
  final String nodeId;

  const SerialSetNodeEntity({
    required this.qrCode,
    required this.serialNo,
    required this.nodeId,
  });

  @override
  List<Object?> get props => [qrCode, serialNo, nodeId];
}
