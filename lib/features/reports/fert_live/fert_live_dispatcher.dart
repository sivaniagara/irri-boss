import '../../../core/services/mqtt/mqtt_message_helper.dart';
import 'fertstate.dart';

class FertilizerLiveDispatcher extends MessageDispatcher {
  void Function(String deviceId, Map<String, dynamic> message)? onFertLiveReceived;

  // Static cache to store the last received state per deviceId
  static final Map<String, FertilizerLiveState> _lastKnownStates = {};

  FertilizerLiveDispatcher();

  @override
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {
    print("onFertilizerLive call for $deviceId");

    // Convert and cache the message
    final newState = fertilizerLiveStateFromRaw(message);
    if (newState.lastSyncTime != "NA") {
      _lastKnownStates[deviceId.trim()] = newState;
    }

    onFertLiveReceived?.call(deviceId, message);
  }

  /// Retrieves the last known state for a specific device
  static FertilizerLiveState? getLastState(String deviceId) {
    return _lastKnownStates[deviceId.trim()];
  }
}
