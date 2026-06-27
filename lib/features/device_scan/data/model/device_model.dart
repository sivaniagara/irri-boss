enum UploadStatus {
  pending,
  success,
  failed,
  alreadyExists,
}

class QRDeviceModel {

  final String deviceId;
  final int modelId;
  final int categoryId;
  final String manufactureDate;
  final int warrentyMonths;

  UploadStatus status;

  QRDeviceModel({
    required this.deviceId,
    required this.modelId,
    required this.categoryId,
    required this.manufactureDate,
    required this.warrentyMonths,
    this.status =
        UploadStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "modelId": modelId,
      "deviceId": deviceId,
      "dateOfManufacture":
      manufactureDate,
      "warrentyMonths":
      warrentyMonths,
    };
  }
}
