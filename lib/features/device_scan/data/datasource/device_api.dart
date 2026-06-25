import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';

class DeviceApi {
  final ApiClient apiClient;

  DeviceApi(this.apiClient);

  /// Save scanned device to server
  Future<void> saveDevice(Map<String, dynamic> deviceData) async {
    try {
      // Replace with your actual endpoint for sending device data
      // await apiClient.post('/api/save-device', data: deviceData);
    } catch (e) {
      throw Exception('Failed to send device data: $e');
    }
  }

  Future<dynamic> uploadBleProducts(Map<String, dynamic> data) async {
    try {
      return await apiClient.post(ApiUrls.postBleProduct, body: data);
    } catch (e) {
      throw Exception('Failed to upload BLE products: $e');
    }
  }

  // getDevices is intentionally omitted as per requirement
}
