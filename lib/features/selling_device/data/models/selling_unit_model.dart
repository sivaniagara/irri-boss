import '../../domain/entities/selling_unit_entity.dart';

class SellingUnitModel extends SellingUnitEntity {
  SellingUnitModel({
    required super.deviceId,
    required super.modelName,
    required super.modelId,
    required super.productId,
    required super.categoryName,
    required super.categoryId,
  });

  factory SellingUnitModel.fromJson(Map<String, dynamic> json) {
    return SellingUnitModel(
      deviceId: json['deviceId'] ?? '',
      modelName: json['modelName'] ?? '',
      modelId: json['modelId'] ?? 0,
      productId: json['productId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'modelName': modelName,
      'modelId': modelId,
      'productId': productId,
      'categoryName': categoryName,
      'categoryId': categoryId,
    };
  }
}
