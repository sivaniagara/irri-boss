import '../../domain/entities/serial_no_entity.dart';

class SerialNoModel extends SerialNoEntity {
  const SerialNoModel({required super.serialNo});

  factory SerialNoModel.fromJson(Map<String, dynamic> json) {
    return SerialNoModel(
      serialNo: json['serialNo'] ?? '000',
    );
  }

  factory SerialNoModel.fromEntity(SerialNoEntity entity) {
    return SerialNoModel(
      serialNo: entity.serialNo,
    );
  }
}
