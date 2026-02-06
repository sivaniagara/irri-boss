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
    required super.userName,
    required super.mobileNumber,
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
      userName: json['userName'],
      mobileNumber: json['mobileNumber'],
    );
  }

  factory MappedNodeModel.fromEntity(MappedNodeEntity entity){
    return MappedNodeModel(
        nodeId: entity.nodeId,
        categoryId: entity.categoryId,
        controllerId: entity.controllerId,
        qrCode: entity.qrCode,
        serialNo: entity.serialNo,
        categoryName: entity.categoryName,
        modelName: entity.modelName,
        dateManufacture: entity.dateManufacture,
        userName: entity.userName,
        mobileNumber: entity.mobileNumber
    );
  }

  String deleteMappedNodePayload(){
    return 'IDSET$serialNo,000,000,000';
  }
}
