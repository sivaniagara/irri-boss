import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/alarm_repository.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository repository;

  AlarmBloc({required this.repository}) : super(AlarmInitial()) {
    on<FetchAlarmDataEvent>((event, emit) async {
      emit(AlarmLoading());
      final result = await repository.getAlarmSetting(
        userId: event.userId,
        controllerId: event.controllerId,
        subUserId: event.subUserId,
      );
      result.fold(
            (failure) => emit(AlarmError(message: failure.message)),
            (success) => emit(AlarmLoaded(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          deviceId: event.deviceId,
          entity: success.copyWith(deviceId: event.deviceId),
        )),
      );
    });

    on<UpdateAlarmFieldEvent>((event, emit) {
      if (state is! AlarmLoaded) return;
      final currentState = state as AlarmLoaded;
      final currentData = currentState.entity.alarmData;

      final updatedData = currentData.copyWith(
        alarmType: event.alarmType,
        alarmActive: event.alarmActive,
        irrigationStop: event.irrigationStop,
        dosingStop: event.dosingStop,
        reset: event.reset,
        hour: event.hour,
        minutes: event.minutes,
        seconds: event.seconds,
        threshold: event.threshold,
      );

      emit(currentState.copyWith(
        updatedEntity: currentState.entity.copyWith(alarmData: updatedData),
      ));
    });

    on<SaveAlarmSettingsEvent>((event, emit) async {
      if (state is! AlarmLoaded) return;
      final currentState = state as AlarmLoaded;
      final entity = currentState.entity;
      final data = entity.alarmData;

      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final String cmdKey = "FL00${data.alarmType}";
      final String command = smsFormats[cmdKey] ?? "ALARMSET";

      // Corrected payload to match old app:
      // COMMAND, MINUTES:SECONDS, ACTIVE, IRR_STOP, DOSING_STOP, THRESHOLD, RESET, HOUR
      final payload = "$command,${data.minutes.padLeft(2, '0')}:${data.seconds.padLeft(2, '0')},${data.alarmActive},${data.irrigationStop},${data.dosingStop},${data.threshold},${data.reset},${data.hour.padLeft(2, '0')}";

      if (kDebugMode) {
        print("ALARM MQTT: Topic: ${currentState.deviceId}, Cmd: $payload");
      }

      final result = await repository.saveAlarmSettings(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
        sentSms: payload,
      );

      result.fold(
            (failure) => emit(AlarmError(message: failure.message)),
            (_) => emit(AlarmSuccess(message: "message delivered", data: entity)),
      );
      emit(currentState);
    });

    on<CancelAlarmEditEvent>((event, emit) {
      if (state is! AlarmLoaded) return;
      final currentState = state as AlarmLoaded;
      add(FetchAlarmDataEvent(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        deviceId: currentState.deviceId,
        subUserId: currentState.subUserId,
      ));
    });
  }

  Map<String, dynamic> _parseSmsFormat(String raw) {
    if (raw.isEmpty) return {};
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }
}
