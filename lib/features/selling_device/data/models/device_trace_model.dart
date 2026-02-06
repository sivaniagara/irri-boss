import '../../domain/entities/device_trace_entity.dart';

class DeviceTraceModel extends DeviceTraceEntity {
  DeviceTraceModel({
    required super.productId,
    required super.categoryName,
    required super.categoryId,
    required super.modelName,
    required super.productDesc,
    required super.dateManufacture,
    required super.warrentyMonths,
  });

  factory DeviceTraceModel.fromJson(Map<String, dynamic> json) {
    return DeviceTraceModel(
      productId: json['productId'] ?? 0,
      categoryName: json['categoryId'] ?? '', // API uses 'categoryId' for name
      categoryId: json['catId'] ?? 0,         // API uses 'catId' for integer ID
      modelName: json['modelId'] ?? '',       // API uses 'modelId' for name string
      productDesc: json['productDesc'] ?? '',
      dateManufacture: json['dateManufacture'] ?? '',
      warrentyMonths: json['warrentyMonths']?.toString() ?? '0',
    );
  }
}
