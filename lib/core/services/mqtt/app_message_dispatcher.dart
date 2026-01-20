import '../../../features/dashboard/utils/dashboard_dispatcher.dart';
import '../../../features/dashboard/utils/program_preview_dispatcher.dart';
import '../../../features/pump_settings/utils/pump_settings_dispatcher.dart';
import '../../../features/reports/fert_live/fert_live_dispatcher.dart';
import 'mqtt_message_helper.dart';

class AppMessageDispatcher extends MessageDispatcher {
  DashboardMessageDispatcher? dashboard;
  PumpSettingsDispatcher? pumpSettings;
  ProgramPreviewDispatcher? programViewDispatcher;
  FertilizerLiveDispatcher? fertilizerLiveDispatcher;

  AppMessageDispatcher({
    this.dashboard,
    this.pumpSettings,
    this.programViewDispatcher,
    this.fertilizerLiveDispatcher
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

  @override
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {
    fertilizerLiveDispatcher?.onFertilizerLive(deviceId, message);
  }

  @override
  void onViewSettings(String deviceId, Map<String, dynamic> message) {
    pumpSettings?.onViewSettings(deviceId, message);
  }
}