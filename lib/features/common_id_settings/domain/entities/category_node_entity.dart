import 'package:niagara_smart_drip_irrigation/features/common_id_settings/domain/entities/serial_no_entity.dart';

import '../../data/models/serial_no_model.dart';

class CategoryNodeEntity {
  final int? nodeId;
  final int categoryId;
  final String categoryName;
  final String qrCode;
  final String nodeName;
  String serialNo;
  int? orderNumber;
  final List<SerialNoEntity> serialNumbers;

  CategoryNodeEntity({
    required this.nodeId,
    required this.categoryId,
    required this.categoryName,
    required this.qrCode,
    required this.nodeName,
    required this.serialNo,
    required this.orderNumber,
    required this.serialNumbers,
  });

  CategoryNodeEntity copyWith(CategoryNodeEntity entity, String? updatedSerialNo){
    return CategoryNodeEntity(
        nodeId: nodeId,
        categoryId: categoryId,
        categoryName: categoryName,
        qrCode: qrCode,
        nodeName: nodeName,
        serialNo: updatedSerialNo ?? serialNo,
        orderNumber: orderNumber,
        serialNumbers: serialNumbers
    );
  }

  bool get isConfigured => nodeId != null && qrCode != '0';
}
