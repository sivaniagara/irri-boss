class NodeStatusEntity {
  final String serialNumber;
  final String category;
  final String deviceName;
  final String status;
  final String value;
  final String latlong;
  final String message;

  NodeStatusEntity({
    required this.serialNumber,
    required this.category,
    required this.deviceName,
    required this.status,
    required this.value,
    required this.latlong,
    required this.message,
  });
}