import '../../domain/entities/mapped_node_entity.dart';

class MappedNodeModel extends MappedNodeEntity {
  MappedNodeModel({
    required super.nodeId,
    required super.categoryId,
    required super.controllerId,
    required super.qrCode,
    required super.serialNo,
    required super.categoryName,
    required super.modelName,
    required super.dateManufacture,
    super.select,
  });

  factory MappedNodeModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return MappedNodeModel(
      nodeId: json['nodeId'],
      categoryId: json['categoryId'],
      controllerId: json['controllerId'],
      qrCode: json['QRCode'],
      serialNo: json['serialNo'],
      categoryName: json['categoryName'],
      modelName: json['modelName'],
      dateManufacture: json['dateManufacture'],
    );
  }
}
