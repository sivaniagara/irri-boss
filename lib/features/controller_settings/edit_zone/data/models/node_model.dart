import '../../domain/entities/zone_configuration_entity.dart';

class NodeModel extends NodeEntity {
  NodeModel({
    required super.nodeId,
    required super.qrCode,
    required super.serialNo,
    required super.modelName,
    required super.categoryName,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      nodeId: json['nodeId'],
      qrCode: json['QRCode'] ?? '',
      serialNo: json['serialNo'] ?? '',
      modelName: json['modelName'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
