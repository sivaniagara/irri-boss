import 'package:niagara_smart_drip_irrigation/core/error/exceptions.dart';
import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_response_handler.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import '../models/selling_device_category_model.dart';
import '../models/selling_unit_model.dart';
import '../models/device_trace_model.dart';
import '../../utils/selling_device_urls.dart';

abstract class SellingDeviceRemoteDataSource {
  Future<List<SellingDeviceCategoryModel>> getCategoryList();
  Future<List<SellingUnitModel>> getSellingUnits(String userId, String categoryId);
  Future<Map<String, String>> getUsernameByMobile(String userId, String mobileNumber, String userType);
  Future<void> sellDevices({
    required String userId,
    required String userName,
    required String userType,
    required String mobileCountryCode,
    required String mobileNumber,
    required List<int> productIds,
  });
  Future<DeviceTraceModel> traceDevice(String userId, String deviceId);
  Future<void> addControllerToDealer({required String userId, required int productId});
}

class SellingDeviceRemoteDataSourceImpl implements SellingDeviceRemoteDataSource {
  final ApiClient apiClient;

  SellingDeviceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SellingDeviceCategoryModel>> getCategoryList() async {
    try {
      final response = await apiClient.get(SellingDeviceUrls.categoryList);
      return handleListResponse<SellingDeviceCategoryModel>(
        response,
        fromJson: (json) => SellingDeviceCategoryModel.fromJson(json),
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (categories) => categories,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SellingUnitModel>> getSellingUnits(String userId, String categoryId) async {
    try {
      final endpoint = buildUrl(SellingDeviceUrls.sellingUnit, {
        "userId": userId,
        "categoryId": categoryId,
      });
      final response = await apiClient.get(endpoint);
      return handleListResponse<SellingUnitModel>(
        response,
        fromJson: (json) => SellingUnitModel.fromJson(json),
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (units) => units,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getUsernameByMobile(String userId, String mobileNumber, String userType) async {
    try {
      final endpoint = buildUrl(SellingDeviceUrls.getUsernameByMobile, {
        "userId": userId,
        "mobileNumber": mobileNumber,
        "userType": userType,
      });
      final response = await apiClient.get(endpoint);

      final code = response['code'] as int?;
      final message = response['message'] as String? ?? '';

      if (code == 200) {
        final data = response['data'];
        final userName = data != null ? (data['userName'] ?? '') : '';
        return {
          "userName": userName,
          "message": message
        };
      } else {
        throw ServerException(message: message.isNotEmpty ? message : 'User not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sellDevices({
    required String userId,
    required String userName,
    required String userType,
    required String mobileCountryCode,
    required String mobileNumber,
    required List<int> productIds,
  }) async {
    try {
      final body = {
        "userId": userId,
        "userName": userName,
        "userType": userType,
        "mobileCountryCode": mobileCountryCode,
        "mobileNumber": mobileNumber,
        "sellingUnits": productIds.map((id) => {"productId": id}).toList(),
      };

      final response = await apiClient.post(SellingDeviceUrls.dealerSales, body: body);
      final code = response['code'] as int?;
      if (code != 200) {
        throw ServerException(message: response['message'] ?? 'Sale failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeviceTraceModel> traceDevice(String userId, String deviceId) async {
    try {
      final endpoint = buildUrl(SellingDeviceUrls.traceDevice, {
        "userId": userId,
        "deviceId": deviceId,
      });
      final response = await apiClient.get(endpoint);

      final code = response['code'] as int?;
      final message = response['message'] as String? ?? '';

      if (code == 200) {
        return DeviceTraceModel.fromJson(response['data']);
      } else {
        throw ServerException(message: message.isNotEmpty ? message : 'Trace failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addControllerToDealer({required String userId, required int productId}) async {
    try {
      final body = {
        "userId": int.parse(userId),
        "productId": productId,
      };
      final response = await apiClient.post('dealer/controller', body: body);
      final code = response['code'] as int?;
      if (code != 200) {
        throw ServerException(message: response['message'] ?? 'Add controller failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
