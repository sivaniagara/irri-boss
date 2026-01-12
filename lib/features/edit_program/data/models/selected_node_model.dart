import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/selected_node_entity.dart';

class SelectedNodeModel extends SelectedNodeEntity {
  SelectedNodeModel({
    required super.nodeId,
    required super.serialNo,
    required super.qrCode,
  });

  factory SelectedNodeModel.fromJson(Map<String, dynamic> json) {
    return SelectedNodeModel(
      nodeId: json['nodeId'],
      serialNo: json['serialNo'] as String,
      qrCode: json['QRCode'] as String,
    );
  }

  factory SelectedNodeModel.fromEntity(SelectedNodeEntity entity) {
    return SelectedNodeModel(
      nodeId: entity.nodeId,
      serialNo: entity.serialNo,
      qrCode: entity.qrCode,
    );
  }

  SelectedNodeEntity toEntity() => this;
}