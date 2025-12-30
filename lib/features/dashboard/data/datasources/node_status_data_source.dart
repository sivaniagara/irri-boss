import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/node_status_model.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/node_status_entity.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../utils/dashboard_urls.dart';

abstract class NodeStatusDataSource {
  Future<List<NodeStatusEntity>> getNodeStatus(int userId, int subuserId, int controllerId);
}

class NodeStatusDataSourceImpl implements NodeStatusDataSource {
  @override
  Future<List<NodeStatusEntity>> getNodeStatus(int userId, int subuserId, int controllerId) async{
    try {
      final endpoint = DashboardUrls.nodeStatusUrl(userId: '$userId', subuserId: '$subuserId', controllerId: '$controllerId');
      final response = await sl.get<ApiClient>().get(endpoint);

      return handleListResponse<NodeStatusModel>(
        response,
        fromJson: (json) => NodeStatusModel.fromJson(json),
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (nodeStatus) => nodeStatus.cast<NodeStatusEntity>(),
      );
    } catch (e) {
      rethrow;
    }
  }
}