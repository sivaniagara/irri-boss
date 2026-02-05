import '../../domain/entities/selling_device_category_entity.dart';

class SellingDeviceCategoryModel extends SellingDeviceCategoryEntity {
  SellingDeviceCategoryModel({
    required super.categoryId,
    required super.categoryName,
  });

  factory SellingDeviceCategoryModel.fromJson(Map<String, dynamic> json) {
    return SellingDeviceCategoryModel(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
