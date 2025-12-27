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
    required StandaloneEntity config,
  }) async {
    try {
      await remoteDataSource.sendStandaloneConfig(
        userId: userId,
        subuserId: subuserId,
        controllerId: controllerId,
        config: config,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> publishMqttCommand({
    required String deviceId,
    required String command,
  }) async {
    try {
      await remoteDataSource.publishMqttCommand(
        deviceId: deviceId,
        command: command,
      );
    } catch (e) {
      rethrow;
    }
  }
}
