import '../../../core/services/mqtt/mqtt_message_helper.dart';

class ProgramPreviewDispatcher extends MessageDispatcher {
  void Function(String deviceId, Map<String, dynamic> message)? onProgramReceived;
  void Function(String deviceId, Map<String, dynamic> message)? onZoneReceived;

  ProgramPreviewDispatcher();

  @override
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {
    print("onProgramReceived :: $message");
    onProgramReceived?.call(deviceId, message);
  }

  @override
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {
    print("onZoneReceived :: $message");
    onZoneReceived?.call(deviceId, message);
  }
}