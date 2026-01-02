import '../../domain/entities/standalone_entity.dart';
import '../../domain/repositories/standalone_repository.dart';
import '../datasources/standalone_remote_datasource.dart';

class StandaloneRepositoryImpl implements StandaloneRepository {
  final StandaloneRemoteDataSource remoteDataSource;

  StandaloneRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StandaloneEntity> getStandaloneStatus({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
  }) async {
    try {
      final model = await remoteDataSource.fetchStandaloneData(
        userId: userId,
        subuserId: subuserId,
        controllerId: controllerId,
        menuId: menuId,
        settingsId: settingsId,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendStandaloneConfig({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
    required StandaloneEntity config,
    required String sentSms,
  }) async {
    try {
      await remoteDataSource.sendStandaloneConfig(
        userId: userId,
        subuserId: subuserId,
        controllerId: controllerId,
        menuId: menuId,
        settingsId: settingsId,
        config: config,
        sentSms: sentSms,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> publishMqttCommand({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String command,
    required String sentSms,
  }) async {
    try {
      // 1. Publish to hardware via MQTT
      await remoteDataSource.publishMqttCommand(
        controllerId: controllerId,
        command: command,
      );

      // 2. Log to history if a non-empty sentSms is provided
      if (sentSms.isNotEmpty) {
        await remoteDataSource.logHistory(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
          sentSms: sentSms,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
