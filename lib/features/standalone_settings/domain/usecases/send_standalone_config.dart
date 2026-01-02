import '../entities/standalone_entity.dart';
import '../repositories/standalone_repository.dart';

class SendStandaloneConfig {
  final StandaloneRepository repository;

  SendStandaloneConfig(this.repository);

  Future<void> call({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
    required StandaloneEntity config,
    required String sentSms,
  }) async {
    return await repository.sendStandaloneConfig(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      menuId: menuId,
      settingsId: settingsId,
      config: config,
      sentSms: sentSms,
    );
  }
}
