
import '../../../core/services/mqtt/mqtt_message_helper.dart';

class FertilizerLiveDispatcher extends MessageDispatcher {
  void Function(String deviceId, Map<String, dynamic> message)? onFertLiveReceived;

  FertilizerLiveDispatcher();

  @override
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {
    // print("onProgramReceived :: $message");
    onFertLiveReceived?.call(deviceId, message);
  }


}



