import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/standalone_entity.dart';
import '../../domain/usecases/get_standalone_status.dart';
import '../../domain/usecases/send_standalone_config.dart';
import '../../domain/usecases/publish_mqtt_command.dart';
import 'standalone_event.dart';
import 'standalone_state.dart';

export 'standalone_event.dart';
export 'standalone_state.dart';

class StandaloneBloc extends Bloc<StandaloneEvent, StandaloneState> {
  final GetStandaloneStatus getStandaloneStatus;
  final SendStandaloneConfig sendStandaloneConfig;
  final PublishMqttCommand publishMqttCommand;

  StandaloneBloc({
    required this.getStandaloneStatus,
    required this.sendStandaloneConfig,
    required this.publishMqttCommand,
  }) : super(StandaloneInitial()) {

    on<FetchStandaloneDataEvent>((event, emit) async {
      // If we already have data and it's not a forced/background refresh,
      // we don't overwrite the current state to preserve local changes.
      if (state is StandaloneLoaded && !event.isBackground) {
        return;
      }

      emit(StandaloneLoading());
      try {
        final result = await getStandaloneStatus(
          userId: event.userId,
          subuserId: int.tryParse(event.subUserId) ?? 0,
          controllerId: event.controllerId,
          menuId: event.menuId,
          settingsId: event.settingsId,
        );

        List<ZoneEntity> finalZones = List<ZoneEntity>.from(result.zones);
        if (result.settingValue == "0") {
          finalZones = finalZones.map((zone) => ZoneEntity(
            zoneNumber: zone.zoneNumber,
            time: zone.time,
            status: false,
          )).toList();
        }

        emit(StandaloneLoaded(
            userId: event.userId,
            controllerId: event.controllerId,
            deviceId: event.deviceId,
            subUserId: event.subUserId,
            data: StandaloneEntity(
              zones: finalZones,
              settingValue: result.settingValue,
              dripSettingValue: result.dripSettingValue,
              programName: result.programName,
            )
        ));
      } catch (e) {
        emit(StandaloneError("Unable to load live settings. Please check your connection."));
      }
    });

    on<ToggleZone>((event, emit) {
      if (state is! StandaloneLoaded) return;
      final currentState = state as StandaloneLoaded;
      final currentStateData = currentState.data;

      if (currentStateData.settingValue != "1" && event.value) return;

      final List<ZoneEntity> updatedZones = currentStateData.zones.asMap().entries.map((entry) {
        if (entry.key == event.index) {
          return ZoneEntity(
            zoneNumber: entry.value.zoneNumber,
            time: entry.value.time,
            status: event.value,
          );
        } else {
          return ZoneEntity(
            zoneNumber: entry.value.zoneNumber,
            time: entry.value.time,
            status: event.value ? false : entry.value.status,
          );
        }
      }).toList();

      emit(currentState.copyWith(
        newData: StandaloneEntity(
          zones: updatedZones,
          settingValue: currentStateData.settingValue,
          dripSettingValue: currentStateData.dripSettingValue,
          programName: currentStateData.programName,
        ),
      ));
    });

    on<UpdateZoneTime>((event, emit) {
      if (state is! StandaloneLoaded) return;
      final currentState = state as StandaloneLoaded;
      final currentStateData = currentState.data;

      final updatedZones = List<ZoneEntity>.from(currentStateData.zones);
      final oldZone = updatedZones[event.index];

      updatedZones[event.index] = ZoneEntity(
        zoneNumber: oldZone.zoneNumber,
        time: event.time,
        status: oldZone.status,
      );

      emit(currentState.copyWith(
        newData: StandaloneEntity(
          zones: updatedZones,
          settingValue: currentStateData.settingValue,
          dripSettingValue: currentStateData.dripSettingValue,
          programName: currentStateData.programName,
        ),
      ));
    });

    on<ToggleStandalone>((event, emit) {
      if (state is! StandaloneLoaded) return;
      final currentState = state as StandaloneLoaded;
      final currentStateData = currentState.data;

      List<ZoneEntity> updatedZones = currentStateData.zones;
      if (!event.value) {
        updatedZones = currentStateData.zones.map((zone) => ZoneEntity(
          zoneNumber: zone.zoneNumber,
          time: zone.time,
          status: false,
        )).toList();
      }

      emit(currentState.copyWith(
        newData: StandaloneEntity(
          zones: updatedZones,
          settingValue: event.value ? "1" : "0",
          dripSettingValue: currentStateData.dripSettingValue,
          programName: currentStateData.programName,
        ),
      ));
    });

    on<ToggleDripStandalone>((event, emit) {
      if (state is! StandaloneLoaded) return;
      final currentState = state as StandaloneLoaded;
      final currentStateData = currentState.data;

      emit(currentState.copyWith(
        newData: StandaloneEntity(
          zones: currentStateData.zones,
          settingValue: currentStateData.settingValue,
          dripSettingValue: event.value ? "1" : "0",
          programName: currentStateData.programName,
        ),
      ));
    });

    on<SendStandaloneConfigEvent>((event, emit) async {
      if (state is! StandaloneLoaded) return;
      final currentState = state as StandaloneLoaded;
      final currentStateData = currentState.data;

      try {
        String sentSms = "";
        bool doMqtt = true;

        if (event.sendType == StandaloneSendType.mode) {
          if (event.menuId == "94") {
            sentSms = currentStateData.settingValue == "1" ? "CONFIGMODEON" : "CONFIGMODEOF";
          } else {
            sentSms = currentStateData.settingValue == "1" ? "STANDALONEMODEON" : "STANDALONEMODEOF";
          }
        } else if (event.sendType == StandaloneSendType.drip) {
          sentSms = currentStateData.dripSettingValue == "1" ? "DRIPMODEON" : "DRIPMODEOF";
        } else if (event.sendType == StandaloneSendType.zones) {
          ZoneEntity? activeZone;
          try {
            activeZone = currentStateData.zones.firstWhere((z) => z.status);
          } catch (_) {}

          if (activeZone != null) {
            final timeParts = activeZone.time.split(':');
            final hh = timeParts[0].padLeft(2, '0');
            final mm = timeParts.length > 1 ? timeParts[1].padLeft(2, '0') : '00';
            sentSms = "STZ,${activeZone.zoneNumber.padLeft(3, '0')},ON,$hh,$mm,";
          } else {
            sentSms = "ZONESETUP";
          }
        }

        if (doMqtt) {
          await publishMqttCommand(
            userId: event.userId,
            subuserId: int.tryParse(event.subUserId) ?? 0,
            controllerId: event.controllerId,
            deviceId: event.deviceId,
            command: json.encode({"sentSms": sentSms}),
            sentSms: "",
          );
        }

        await sendStandaloneConfig(
          userId: event.userId,
          subuserId: int.tryParse(event.subUserId) ?? 0,
          controllerId: event.controllerId,
          menuId: event.menuId,
          settingsId: event.settingsId,
          config: currentStateData,
          sentSms: sentSms,
        );

        emit(StandaloneSuccess(event.successMessage, currentStateData));
        emit(currentState.copyWith(newData: currentStateData));

      } catch (e) {
        emit(StandaloneError("Settings update failed. Please try again."));
      }
    });

    on<ViewStandaloneEvent>((event, emit) async {
      if (state is! StandaloneLoaded && state is! StandaloneSuccess) return;
      final currentStateData = (state is StandaloneLoaded)
          ? (state as StandaloneLoaded).data
          : (state as StandaloneSuccess).data;

      try {
        final statusMsg = "VSTANDALONEMODE";
        final cmd = json.encode({"sentSms": statusMsg});

        await publishMqttCommand(
          userId: event.userId,
          subuserId: int.tryParse(event.subUserId) ?? 0,
          controllerId: event.controllerId,
          deviceId: event.deviceId,
          command: cmd,
          sentSms: statusMsg,
        );

        emit(StandaloneSuccess(event.successMessage, currentStateData));
      } catch (e) {
        emit(StandaloneError("View status failed."));
      }
    });
  }
}
