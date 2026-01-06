import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_response_handler.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/data/models/shared_devices_model.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_urls.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/exceptions.dart';

abstract class SharedDevicesDataSource{
  Future<List<SharedDevicesEntity>> getSharedDevices(String userId);
}

class SharedDeviceDataSourceImpl implements SharedDevicesDataSource {
  @override
  Future<List<SharedDevicesEntity>> getSharedDevices(String userId) async{
    try {
      final endpoint = buildUrl(DealerUrls.getCustomerSharedDevice, {"userId": userId});
      final response = await sl.get<ApiClient>().get(endpoint);

      return handleListResponse<SharedDevicesModel>(
          response,
          fromJson: (json) => SharedDevicesModel.fromJson(json))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (devices) => devices.cast<SharedDevicesEntity>(),
      );
    } catch(e) {
      rethrow;
    }
  }
}