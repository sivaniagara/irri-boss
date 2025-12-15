import '../../domain/entities/zone_entity.dart';

class ZoneModel extends ZoneEntity {
  ZoneModel({
    required super.zoneId,
    required super.zoneName,
    required super.nodeId,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      zoneId: json['zoneId'],
      zoneName: json['zoneName'],
      nodeId: json['nodeId'],
    );
  }
}
