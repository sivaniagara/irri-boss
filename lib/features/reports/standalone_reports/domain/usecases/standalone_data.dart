import '../entities/standalone_entities.dart';
import '../repositories/standalone_repo.dart';

class FetchStandaloneData {
  final StandaloneRepository repository;

  FetchStandaloneData({required this.repository});

  Future<StandaloneEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getStandaloneData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
