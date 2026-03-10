import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/enums/resend_command_enum.dart';

class MappedNodeEntity {
  final int nodeId;
  final int categoryId;
  final int controllerId;
  final String qrCode;
  final String serialNo;
  final String categoryName;
  final String modelName;
  final String dateManufacture;
  final String userName;
  final String mobileNumber;
  bool select;
  ResendCommandEnum status;

  MappedNodeEntity({
    required this.nodeId,
    required this.categoryId,
    required this.controllerId,
    required this.qrCode,
    required this.serialNo,
    required this.categoryName,
    required this.modelName,
    required this.dateManufacture,
    required this.userName,
    required this.mobileNumber,
    this.select = false,
    this.status = ResendCommandEnum.idle,
  });

  MappedNodeEntity copyWidth({bool? isSelect, ResendCommandEnum? status}){
    return MappedNodeEntity(
        nodeId: nodeId,
        categoryId: categoryId,
        controllerId: controllerId,
        qrCode: qrCode,
        serialNo: serialNo,
        categoryName: categoryName,
        modelName: modelName,
        dateManufacture: dateManufacture,
        userName: userName,
        mobileNumber: mobileNumber,
      select: isSelect ?? select,
      status: status ?? this.status
    );
  }
}
