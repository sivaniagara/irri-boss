import '../entities/standalone_entity.dart';

abstract class StandaloneRepository {
  Future<StandaloneEntity> getStandaloneStatus({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
  });

  Future<void> sendStandaloneConfig({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
    required StandaloneEntity config,
    required String sentSms,
  });

  Future<void> publishMqttCommand({
    required String deviceId,
    required String command,
  });
}
