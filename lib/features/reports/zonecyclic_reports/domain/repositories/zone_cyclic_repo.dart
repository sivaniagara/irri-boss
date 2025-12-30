


import '../entities/zone_cyclic_entities.dart';

abstract class ZoneCyclicRepository {
  Future<ZoneCyclicEntity> getZoneCyclicData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}