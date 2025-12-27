import '../entities/standalone_entity.dart';
import '../repositories/standalone_repository.dart';

class SendStandaloneConfig {
  final StandaloneRepository repository;

  SendStandaloneConfig(this.repository);

  Future<void> call({
    required String userId,
    required int subuserId,
    required String controllerId,
    required StandaloneEntity config,
  }) async {
    return await repository.sendStandaloneConfig(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      config: config,
    );
  }
}
