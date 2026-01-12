import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/node_entity.dart';

class NodeModel extends NodeEntity {
  NodeModel({
    required super.nodeId,
    required super.qrCode,
    required super.serialNo,
    required super.modelName,
    required super.categoryName,
    required super.select,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      nodeId: json['nodeId'] as int,
      qrCode: json['QRCode'] as String,
      serialNo: json['serialNo'] as String,
      modelName: json['modelName'] as String,
      categoryName: json['categoryName'] as String,
      select: false, // default when coming from API
    );
  }

  factory NodeModel.fromEntity(NodeEntity entity) {
    return NodeModel(
      nodeId: entity.nodeId,
      qrCode: entity.qrCode,
      serialNo: entity.serialNo,
      modelName: entity.modelName,
      categoryName: entity.categoryName,
      select: entity.select,
    );
  }

  NodeEntity toEntity() {
    return NodeEntity(
      nodeId: nodeId,
      qrCode: qrCode,
      serialNo: serialNo,
      modelName: modelName,
      categoryName: categoryName,
      select: select,
    );
  }
}