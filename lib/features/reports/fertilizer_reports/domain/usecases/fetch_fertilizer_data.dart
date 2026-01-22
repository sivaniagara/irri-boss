

import '../entities/fertilizer_entities.dart';
import '../repositories/fertilizer_repo.dart';

class FetchFertilizerData {
  final FertilizerRepository repository;

  FetchFertilizerData({required this.repository});

  Future<FertilizerEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getFertilizerData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
