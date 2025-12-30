import '../../../features/dashboard/utils/dashboard_dispatcher.dart';
import '../../../features/dashboard/utils/program_preview_dispatcher.dart';
import '../../../features/pump_settings/utils/pump_settings_dispatcher.dart';
import 'mqtt_message_helper.dart';

class AppMessageDispatcher extends MessageDispatcher {
  DashboardMessageDispatcher? dashboard;
  PumpSettingsDispatcher? pumpSettings;
  ProgramPreviewDispatcher? programViewDispatcher;

  AppMessageDispatcher({
    this.dashboard,
    this.pumpSettings,
    this.programViewDispatcher
  });

  @override
  void onLiveUpdate(String deviceId, liveMessage) {
    dashboard?.onLiveUpdate(deviceId, liveMessage);
  }

  @override
  void onPumpWaterPumpSettings(String deviceId, String message) {
    pumpSettings?.onPumpWaterPumpSettings(deviceId, message);
  }

  @override
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {
    programViewDispatcher?.onScheduleOne(deviceId, message);
  }

  @override
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {
    programViewDispatcher?.onScheduleOne(deviceId, message);
  }
}
