import '../entities/moisture_entities.dart';
import '../repositories/moisture_repo.dart';

class FetchMoistureData {
  final MoistureRepository repository;

  FetchMoistureData({required this.repository});

  Future<MoistureEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
   }) {
    return repository.getMoistureData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
     );
  }
}
