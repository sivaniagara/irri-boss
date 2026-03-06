import '../../../features/dashboard/utils/dashboard_dispatcher.dart';
import '../../../features/dashboard/utils/program_preview_dispatcher.dart';
import '../../../features/pump_settings/utils/pump_settings_dispatcher.dart';
import '../../../features/reports/fert_live/fert_live_dispatcher.dart';
import '../../../features/dashboard/domain/entities/livemessage_entity.dart';
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
    this.fertilizerLiveDispatcher,
  });

  // ✅ LIVE DATA (UPDATED SIGNATURE)
  @override
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage, {String? date, String? fullMsg, String? msgDesc, String? time}) {
    dashboard?.onLiveUpdate(deviceId, liveMessage, date: date, fullMsg: fullMsg, msgDesc: msgDesc, time: time);
  }

  // ✅ SERVER TIME UPDATE (FOR ALL MQTT PACKETS)
  @override
  void onServerTimeUpdate(String deviceId, {String? date, String? time}) {
    dashboard?.onServerTimeUpdate(deviceId, date: date, time: time);
  }

  // ✅ PUMP SETTINGS
  @override
  void onPumpWaterPumpSettings(String deviceId, String message) {
    pumpSettings?.onPumpWaterPumpSettings(deviceId, message);
  }

  // ✅ SCHEDULE ONE
  @override
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {
    programViewDispatcher?.onScheduleOne(deviceId, message);
  }

  // ✅ SCHEDULE TWO
  @override
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {
    programViewDispatcher?.onScheduleTwo(deviceId, message);
  }

  // ✅ FERTILIZER LIVE
  @override
  void onFertilizerUpdate(String deviceId, String rawMessage) {
    fertilizerLiveDispatcher?.onFertilizerUpdate(deviceId, rawMessage);
  }
  @override
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {
    fertilizerLiveDispatcher?.onFertilizerLive(deviceId, message);
  }

  // ✅ VIEW / SETTINGS
  @override
  void onViewSettings(String deviceId, Map<String, dynamic> message) {
    pumpSettings?.onViewSettings(deviceId, message);
  }

}
