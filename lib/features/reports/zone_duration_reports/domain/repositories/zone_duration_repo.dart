



import '../entities/zone_duration_entities.dart';

abstract class ZoneDurationRepository {
  Future<ZoneDurationEntity> getZoneDurationData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}