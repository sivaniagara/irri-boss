import '../entities/standalone_entity.dart';
import '../repositories/standalone_repository.dart';

class GetStandaloneStatus {
  final StandaloneRepository repository;

  GetStandaloneStatus(this.repository);

  Future<StandaloneEntity> call({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
  }) async {
    return await repository.getStandaloneStatus(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      menuId: menuId,
      settingsId: settingsId,
    );
  }
}
