import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/common_id_settings/data/models/serial_no_model.dart';

import '../../domain/entities/category_node_entity.dart';


class CategoryNodeModel extends CategoryNodeEntity {
  CategoryNodeModel({
    required super.nodeId,
    required super.categoryId,
    required super.categoryName,
    required super.qrCode,
    required super.nodeName,
    required super.serialNo,
    required super.orderNumber,
    required super.serialNumbers,
  });

  factory CategoryNodeModel.fromJson(Map<String, dynamic> json) {
    return CategoryNodeModel(
      nodeId: _toNullableInt(json['nodeId']),
      categoryId: _toInt(json['categoryId']),
      categoryName: json['categoryName'] ?? '',
      qrCode: json['QRCode'] ?? '0',
      nodeName: json['nodeName'] ?? '',
      serialNo: json['serialNo'] ?? '000',
      orderNumber: _toNullableInt(json['orderNumber']),
      serialNumbers: (json['serialNoList'] as List<dynamic>? ?? [])
          .where((e) => e['serialNo'] != '000')
          .map((e) => SerialNoModel.fromJson(e))
          .toList(),
    );
  }

  factory CategoryNodeModel.fromEntity(CategoryNodeEntity entity) {
    return CategoryNodeModel(
      nodeId: entity.nodeId,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      qrCode: entity.qrCode,
      nodeName: entity.nodeName,
      serialNo: entity.serialNo,
      orderNumber: entity.orderNumber,
      serialNumbers: entity.serialNumbers.map<SerialNoModel>((e){
        return SerialNoModel.fromEntity(e);
      }).toList(),
    );
  }

  static int _toInt(dynamic value) =>
      int.tryParse(value.toString()) ?? 0;

  static int? _toNullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return int.tryParse(value.toString());
  }
}
