import 'dart:convert';

import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/dealer_customer_entity.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../../../core/utils/api_urls.dart';
import '../models/dealer_customer_model.dart';
import '../../utils/dealer_urls.dart';
import '../../../../core/di/injection.dart';

abstract class DealerDashboardRemoteDataSource {
  Future<List<DealerCustomerEntity>> getDealerCustomerDetails(String userId);
  Future<List<DealerCustomerEntity>> getSelectedCustomerDetails(String userId);
}

class DealerDashboardRemoteDataSourceImpl implements DealerDashboardRemoteDataSource {

  DealerDashboardRemoteDataSourceImpl();

  @override
  Future<List<DealerCustomerEntity>> getDealerCustomerDetails(String userId) async {
    try {
      final endpoint = buildUrl(DealerUrls.getDealerCustomerDetails, {"userId": userId});
      final response = await sl.get<ApiClient>().get(endpoint);

      return handleListResponse<DealerCustomerModel>(
          response,
          fromJson: (json) => DealerCustomerModel.fromJson(json))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (devices) => devices.cast<DealerCustomerEntity>(),
      );
    } catch(e) {
      rethrow;
    }
  }

  @override
  Future<List<DealerCustomerEntity>> getSelectedCustomerDetails(String userId) async {
    try {
      final endpoint = buildUrl(DealerUrls.getSelectedCustomerDeviceListItem, {"dealerId": userId});
      final response = await sl.get<ApiClient>().get(endpoint);

      return handleListResponse<DealerCustomerModel>(
          response,
          fromJson: (json) => DealerCustomerModel.fromJson(json))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (devices) => devices.cast<DealerCustomerEntity>(),
      );
    } catch(e) {
      rethrow;
    }
  }
}
