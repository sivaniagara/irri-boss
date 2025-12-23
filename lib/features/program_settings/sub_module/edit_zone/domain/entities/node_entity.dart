class NodeEntity {
  final int nodeId;
  final String qrCode;
  final String serialNo;
  final String modelName;
  final String categoryName;
  final bool select;

  NodeEntity({
    required this.nodeId,
    required this.qrCode,
    required this.serialNo,
    required this.modelName,
    required this.categoryName,
    required this.select,
  });

  NodeEntity copyWith({bool? select}) {
    return NodeEntity(
      nodeId: nodeId,
      qrCode: qrCode,
      serialNo: serialNo,
      modelName: modelName,
      categoryName: categoryName,
      select: select ?? this.select,
    );
  }
}
