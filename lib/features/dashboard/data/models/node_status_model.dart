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
        serialNumber: json["serialNumber"]?.toString() ?? "",
        category: json["category"]?.toString() ?? "",
        deviceName: json["deviceName"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        value: json["value"]?.toString() ?? "",
        latlong: json["latlong"]?.toString() ?? "",
        message: json["message"]?.toString() ?? ""
    );
  }
}