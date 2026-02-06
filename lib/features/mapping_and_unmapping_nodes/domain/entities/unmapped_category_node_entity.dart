class UnmappedCategoryNodeEntity {
  final int nodeId;
  final int categoryId;
  final String qrCode;
  final String modelName;
  final String dateManufacture;
  final String userName;
  final String mobileNumber;
  bool select;

  UnmappedCategoryNodeEntity({
    required this.nodeId,
    required this.categoryId,
    required this.qrCode,
    required this.modelName,
    required this.dateManufacture,
    required this.userName,
    required this.mobileNumber,
    this.select = false
  });

  UnmappedCategoryNodeEntity copyWith(){
    return UnmappedCategoryNodeEntity(
        nodeId: nodeId,
        categoryId: categoryId,
        qrCode: qrCode,
        modelName: modelName,
        dateManufacture: dateManufacture,
        userName: userName,
        mobileNumber: mobileNumber,
    );
  }
}
