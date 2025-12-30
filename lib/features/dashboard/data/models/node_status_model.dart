import '../../domain/entities/node_status_entity.dart';

class NodeStatusModel extends NodeStatusEntity {
  NodeStatusModel({
    required super.serialNumber,
    required super.category,
    required super.deviceName,
    required super.status,
    required super.value,
    required super.latlong,
    required super.message
  });

  factory NodeStatusModel.fromJson(Map<String, dynamic> json) {
    return NodeStatusModel(
        serialNumber: json["serialNumber"],
        category: json["category"],
        deviceName: json["deviceName"],
        status: json["status"],
        value: json["value"],
        latlong: json["latlong"],
        message: json["message"]
    );
  }
}