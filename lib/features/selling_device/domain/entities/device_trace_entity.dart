class DeviceTraceEntity {
  final int productId;
  final String categoryName;
  final int categoryId;
  final String modelName;
  final String productDesc;
  final String dateManufacture;
  final String warrentyMonths;

  DeviceTraceEntity({
    required this.productId,
    required this.categoryName,
    required this.categoryId,
    required this.modelName,
    required this.productDesc,
    required this.dateManufacture,
    required this.warrentyMonths,
  });
}
