import '../../domain/entities/node_entity.dart';

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
      nodeId: json['nodeId'],
      qrCode: json['QRCode'] ?? '',
      serialNo: json['serialNo'] ?? '',
      modelName: json['modelName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      select: false
    );
  }

  NodeEntity toEntity(){
    return NodeEntity(
        nodeId: nodeId,
        qrCode: qrCode,
        serialNo: serialNo,
        modelName: modelName,
        categoryName: categoryName,
        select: select
    );
  }
}
