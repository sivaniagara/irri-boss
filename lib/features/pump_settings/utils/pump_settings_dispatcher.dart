// pump_settings_dispatcher.dart

import '../../../core/services/mqtt/mqtt_message_helper.dart';
import '../presentation/cubit/view_pump_settings_cubit.dart';

class PumpSettingsDispatcher extends MessageDispatcher {
  final ViewPumpSettingsCubit cubit;

  PumpSettingsDispatcher(this.cubit);

  @override
  void onPumpWaterPumpSettings(String deviceId, String message) {
    print("Pump settings received from device $deviceId: $message");

    // Correctly update the cubit with the received JSON settings
    cubit.onSettingsReceived(message);
  }
}