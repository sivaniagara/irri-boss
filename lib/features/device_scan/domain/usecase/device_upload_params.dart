import '../../data/model/device_model.dart';

class DeviceUploadParams {

  final int userId;

  final List<QRDeviceModel>
  devices;

  DeviceUploadParams({
    required this.userId,
    required this.devices,
  });

  Map<String, dynamic>
  toJson() {

    return {

      "userId": userId,

      "productList": devices.map((e,) => {"categoryId":e.categoryId, "modelId": e.modelId, "deviceId":e.deviceId,
          "dateOfManufacture": e.manufactureDate, "warrentyMonths":e.warrentyMonths,
        },
      )
          .toList(),
    };
  }
}