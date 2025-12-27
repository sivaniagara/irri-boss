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

  factory UnmappedCategoryNodeModel.fromEntity(UnmappedCategoryNodeEntity entity) {
    return UnmappedCategoryNodeModel(
      nodeId: entity.nodeId,
      categoryId: entity.categoryId,
      qrCode: entity.qrCode,
      modelName: entity.modelName,
      dateManufacture: entity.dateManufacture,
    );
  }

  Map<String, dynamic> formPayload(String categoryId){
    return {
      'nodeId' : nodeId,
      'sentSms' : 'IDSET,${splitQrCode(qrCode)}',
      'categoryId' : categoryId
    };
  }

  String splitQrCode(String qrCode){
    int chunkSize = 3;
    List<String> splitList = [
      for (int i = 0; i < qrCode.length; i += chunkSize)
        qrCode.substring(i, i + chunkSize > qrCode.length ? qrCode.length : i + chunkSize)
    ];
    return splitList.join(',');
  }
}
