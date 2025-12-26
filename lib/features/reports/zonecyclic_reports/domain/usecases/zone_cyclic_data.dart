
import '../entities/zone_cyclic_entities.dart';
import '../repositories/zone_cyclic_repo.dart';

class FetchZoneCyclicData {
  final ZoneCyclicRepository repository;

  FetchZoneCyclicData({required this.repository});

  Future<ZoneCyclicEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getZoneCyclicData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
