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
      emit(StandaloneLoading());

      try {
        final result = await getStandaloneStatus(
          userId: event.userId,
          subuserId: 0,
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
          StandaloneEntity(
            zones: finalZones,
            settingValue: result.settingValue,
            dripSettingValue: result.dripSettingValue,
          )
        ));
      } catch (e) {
        // Updated: Show user-friendly message instead of raw error/URLs
        emit(StandaloneError("Unable to load settings. Please check your connection and try again."));
      }
    });

    on<ToggleZone>((event, emit) {
      if (state is StandaloneLoaded || state is StandaloneSuccess) {
        final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;

        if (currentStateData.settingValue != "1" && event.value) {
          return;
        }

        final updatedZones = List<ZoneEntity>.from(currentStateData.zones);
        final oldZone = updatedZones[event.index];
        
        updatedZones[event.index] = ZoneEntity(
          zoneNumber: oldZone.zoneNumber,
          time: oldZone.time,
          status: event.value,
        );

        emit(StandaloneLoaded(
          StandaloneEntity(
            zones: updatedZones,
            settingValue: currentStateData.settingValue,
            dripSettingValue: currentStateData.dripSettingValue,
          ),
        ));
      }
    });

    on<UpdateZoneTime>((event, emit) {
      if (state is StandaloneLoaded || state is StandaloneSuccess) {
        final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;

        final updatedZones = List<ZoneEntity>.from(currentStateData.zones);
        final oldZone = updatedZones[event.index];
        
        updatedZones[event.index] = ZoneEntity(
          zoneNumber: oldZone.zoneNumber,
          time: event.time,
          status: oldZone.status,
        );

        emit(StandaloneLoaded(
          StandaloneEntity(
            zones: updatedZones,
            settingValue: currentStateData.settingValue,
            dripSettingValue: currentStateData.dripSettingValue,
          ),
        ));
      }
    });

    on<ToggleStandalone>((event, emit) {
      if (state is StandaloneLoaded || state is StandaloneSuccess) {
        final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;
        
        List<ZoneEntity> updatedZones = currentStateData.zones;
        if (!event.value) {
          updatedZones = currentStateData.zones.map((zone) => ZoneEntity(
            zoneNumber: zone.zoneNumber,
            time: zone.time,
            status: false,
          )).toList();
        }

        emit(StandaloneLoaded(
          StandaloneEntity(
            zones: updatedZones,
            settingValue: event.value ? "1" : "0",
            dripSettingValue: currentStateData.dripSettingValue,
          ),
        ));
      }
    });

    on<ToggleDripStandalone>((event, emit) {
      if (state is StandaloneLoaded || state is StandaloneSuccess) {
        final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;

        emit(StandaloneLoaded(
          StandaloneEntity(
            zones: currentStateData.zones,
            settingValue: currentStateData.settingValue,
            dripSettingValue: event.value ? "1" : "0",
          ),
        ));
      }
    });

    on<SendStandaloneConfigEvent>((event, emit) async {
       if (state is StandaloneLoaded || state is StandaloneSuccess) {
         final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;

         try {
           String sentSms = "";
           if (currentStateData.zones.isNotEmpty) {
             final zone = currentStateData.zones[0];
             final statusStr = zone.status ? "ON" : "OFF";
             final timeParts = zone.time.split(':');
             final hours = timeParts.isNotEmpty ? timeParts[0].padLeft(2, '0') : "00";
             final minutes = timeParts.length > 1 ? timeParts[1].padLeft(2, '0') : "00";
             final zoneNumPadded = zone.zoneNumber.padLeft(3, '0');
             sentSms = "STZ,$zoneNumPadded,$statusStr,$hours,$minutes";
           }

           for (var zone in currentStateData.zones) {
             final statusStr = zone.status ? "ON" : "OFF";
             final timeParts = zone.time.split(':');
             final hours = timeParts.length > 0 ? timeParts[0].padLeft(2, '0') : "00";
             final minutes = timeParts.length > 1 ? timeParts[1].padLeft(2, '0') : "00";
             final zoneNumPadded = zone.zoneNumber.padLeft(3, '0');
             final mqttPayload = json.encode({
               "sentSms": "STZ,$zoneNumPadded,$statusStr,$hours,$minutes"
             });
             await publishMqttCommand(deviceId: event.controllerId, command: mqttPayload);
           }

           try {
             await sendStandaloneConfig(
               userId: event.userId,
               subuserId: 0,
               controllerId: event.controllerId,
               menuId: event.menuId,
               settingsId: event.settingsId,
               config: currentStateData,
               sentSms: sentSms,
             );
           } catch (apiError) {
             if (kDebugMode) print("API Update failed: $apiError");
           }

           emit(StandaloneSuccess(event.successMessage, currentStateData));

         } catch (e) {
           if (kDebugMode) print("Error in SEND event: $e");
           // Updated: User friendly error message
           emit(StandaloneError("Failed to update settings. Please try again."));
         }
       }
    });

    on<ViewStandaloneEvent>((event, emit) async {
      if (state is StandaloneLoaded || state is StandaloneSuccess) {
        final currentStateData = (state is StandaloneLoaded) 
            ? (state as StandaloneLoaded).data 
            : (state as StandaloneSuccess).data;

        try {
          final statusMsg = "STANDALONE:${currentStateData.settingValue},DRIP:${currentStateData.dripSettingValue}";
          final mqttPayload = json.encode({
            "sentSms": statusMsg
          });

          await publishMqttCommand(
            deviceId: event.controllerId,
            command: mqttPayload,
          );

          emit(StandaloneSuccess(event.successMessage, currentStateData));
        } catch (e) {
          if (kDebugMode) print("Error in VIEW event: $e");
          emit(StandaloneError("Unable to fetch status at this time."));
        }
      }
    });
  }
}
