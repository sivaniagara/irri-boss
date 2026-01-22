
import '../entities/fertilizer_entities.dart';

abstract class FertilizerRepository {
  Future<FertilizerEntity> getFertilizerData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}