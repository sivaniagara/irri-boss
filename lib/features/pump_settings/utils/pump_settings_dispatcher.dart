import '../../../core/services/mqtt/mqtt_message_helper.dart';
import '../presentation/cubit/pump_settings_cubit.dart';
import '../presentation/cubit/pump_settings_view_response_cubit.dart';
import '../presentation/cubit/view_pump_settings_cubit.dart';

class PumpSettingsDispatcher extends MessageDispatcher {
  final ViewPumpSettingsCubit? cubit;
  final PumpSettingsViewResponseCubit? pumpSettings;
  final PumpSettingsCubit? pumpSettingsCubit;

  PumpSettingsDispatcher({this.cubit, this.pumpSettings, this.pumpSettingsCubit});

  @override
  void onPumpWaterPumpSettings(String deviceId, String message) {
    cubit?.onSettingsReceived(message);
  }

  @override
  void onViewSettings(String deviceId, Map<String, dynamic> message) {
    pumpSettings?.onViewMessageReceived(message);
  }

  @override
  void onNewViewSettings(String deviceId, String message) {
    pumpSettingsCubit?.onViewMessageReceived(message);
  }

}