import '../../domain/entities/unmapped_category_node_entity.dart';

class UnmappedCategoryNodeModel extends UnmappedCategoryNodeEntity {
  UnmappedCategoryNodeModel({
    required super.nodeId,
    required super.categoryId,
    required super.qrCode,
    required super.modelName,
    required super.dateManufacture,
    super.select
  });

  factory UnmappedCategoryNodeModel.fromJson(Map<String, dynamic> json) {
    return UnmappedCategoryNodeModel(
      nodeId: json['nodeId'],
      categoryId: json['categoryId'],
      qrCode: json['QRCode'],
      modelName: json['modelName'],
      dateManufacture: json['dateManufacture'],
    );
  }
}
