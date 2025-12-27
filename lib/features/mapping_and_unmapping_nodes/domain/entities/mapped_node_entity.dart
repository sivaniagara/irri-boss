class MappedNodeEntity {
  final int nodeId;
  final int categoryId;
  final int controllerId;
  final String qrCode;
  final String serialNo;
  final String categoryName;
  final String modelName;
  final String dateManufacture;
  bool select;

  MappedNodeEntity({
    required this.nodeId,
    required this.categoryId,
    required this.controllerId,
    required this.qrCode,
    required this.serialNo,
    required this.categoryName,
    required this.modelName,
    required this.dateManufacture,
    this.select = false,
  });

  MappedNodeEntity copyWidth([bool? isSelect]){
    return MappedNodeEntity(
        nodeId: nodeId,
        categoryId: categoryId,
        controllerId: controllerId,
        qrCode: qrCode,
        serialNo: serialNo,
        categoryName: categoryName,
        modelName: modelName,
        dateManufacture: dateManufacture,
      select: isSelect ?? select
    );
  }
}
