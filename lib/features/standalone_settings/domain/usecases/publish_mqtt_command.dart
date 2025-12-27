import '../repositories/standalone_repository.dart';

class PublishMqttCommand {
  final StandaloneRepository repository;

  PublishMqttCommand(this.repository);

  Future<void> call({
    required String deviceId,
    required String command,
  }) async {
    return await repository.publishMqttCommand(
      deviceId: deviceId,
      command: command,
    );
  }
}
