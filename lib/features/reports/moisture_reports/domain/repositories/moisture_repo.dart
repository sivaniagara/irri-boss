


import '../entities/moisture_entities.dart';

abstract class MoistureRepository {
  Future<MoistureEntity> getMoistureData({
    required int userId,
    required int subuserId,
    required int controllerId,
   });
}