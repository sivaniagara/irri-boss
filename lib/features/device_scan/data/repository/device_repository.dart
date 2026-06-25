import '../datasource/device_api.dart';
import '../model/device_model.dart';

class DeviceRepository {
  final DeviceApi api;

  DeviceRepository(this.api);

  /// Returns an empty list as the API does not support fetching devices
  Future<List<QRDeviceModel>> getDevices() async {
    // API only supports sending data, fetching list is not available.
    return [];
  }

  /// Save scanned device to server
  Future<void> saveDevice(QRDeviceModel device) async {
    try {
      await api.saveDevice(device.toJson());
    } catch (e) {
      throw Exception('Failed to save device: $e');
    }
  }

  Future<dynamic> uploadBleProducts(int userId, List<QRDeviceModel> devices) async {
    final data = {
      "userId": userId,
      "productList": devices.map((e) => e.toJson()).toList(),
    };
    return await api.uploadBleProducts(data);
  }
}
