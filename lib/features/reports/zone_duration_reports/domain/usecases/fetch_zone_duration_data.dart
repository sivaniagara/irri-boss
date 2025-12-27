
import '../entities/zone_duration_entities.dart';
import '../repositories/zone_duration_repo.dart';

class FetchZoneDurationData {
  final ZoneDurationRepository repository;

  FetchZoneDurationData({required this.repository});

  Future<ZoneDurationEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getZoneDurationData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
