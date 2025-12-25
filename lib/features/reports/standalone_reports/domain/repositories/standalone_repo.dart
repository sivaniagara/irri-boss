
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/domain/entities/standalone_entities.dart';

abstract class StandaloneRepository {
  Future<StandaloneEntity> getStandaloneData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}