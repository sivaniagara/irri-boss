import '../repositories/standalone_repository.dart';

class PublishMqttCommand {
  final StandaloneRepository repository;

  PublishMqttCommand(this.repository);

  Future<void> call({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String command,
    required String sentSms,
  }) async {
    return await repository.publishMqttCommand(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      command: command,
      sentSms: sentSms,
    );
  }
}
