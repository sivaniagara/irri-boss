import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD


import '../../domain/entities/valve_flow_entity.dart';
import '../../domain/repositories/valve_flow_repository.dart';
=======
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/domain/repositories/valve_flow_repository.dart';
import '../../domain/entities/valve_flow_entity.dart';
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
import 'valve_flow_event.dart';
import 'valve_flow_state.dart';

class ValveFlowBloc extends Bloc<ValveFlowEvent, ValveFlowState> {
  final ValveFlowRepository repository;

  ValveFlowBloc({required this.repository}) : super(ValveFlowInitial()) {
    on<FetchValveFlowDataEvent>((event, emit) async {
      emit(ValveFlowLoading());
      final result = await repository.getValveFlowSetting(
        userId: event.userId,
        controllerId: event.controllerId,
        subUserId: event.subUserId,
      );
      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (success) => emit(ValveFlowLoaded(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          deviceId: event.deviceId,
          entity: success.copyWith(deviceId: event.deviceId),
        )),
      );
    });

    on<UpdateValveFlowNodeEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final currentEntity = currentState.entity;

      final updatedNodes = List<ValveFlowNodeEntity>.from(currentEntity.nodes);
      updatedNodes[event.index] = updatedNodes[event.index].copyWith(nodeValue: event.nodeValue);

      emit(currentState.copyWith(
        updatedEntity: currentEntity.copyWith(nodes: updatedNodes),
      ));
    });

    on<UpdateCommonFlowDeviationEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      emit(currentState.copyWith(
        updatedEntity: currentState.entity.copyWith(flowDeviation: event.deviation),
      ));
    });

    on<SendValveFlowSmsEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.entity;

      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final node = entity.nodes[event.index];
      final command = smsFormats['F001'] ?? 'FLOWVALSET';
<<<<<<< HEAD

=======
<<<<<<< HEAD
      
      // Mirroring old app format: COMMAND,serialNo,value
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
      final payload = "$command,${node.serialNo},${node.nodeValue}".replaceAll(RegExp(r'\s+'), '');

      if (kDebugMode) {
        print("VALVE FLOW MQTT: Topic: ${currentState.deviceId}, Cmd: $payload");
      }

      final result = await repository.saveValveFlowSettings(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
=======
      final payload = "$command,${node.serialNo},${node.nodeValue}".replaceAll(RegExp(r'\s+'), '');

      final result = await repository.publishValveFlowSms(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
        sentSms: payload,
      );

      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (_) => emit(ValveFlowSuccess(message: "Valve setting sent successfully", data: entity)),
      );
<<<<<<< HEAD
=======
      // Re-emit loaded state
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
      emit(currentState);
    });

    on<SaveCommonDeviationEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.entity;

      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final command = smsFormats['F002'] ?? 'FLOWDEV';
<<<<<<< HEAD

=======
<<<<<<< HEAD
      
      // Mirroring old app format: COMMAND,value
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
      final payload = "$command,${entity.flowDeviation}".replaceAll(RegExp(r'\s+'), '');

      if (kDebugMode) {
        print("VALVE DEVIATION MQTT: Topic: ${currentState.deviceId}, Cmd: $payload");
      }

      final result = await repository.saveValveFlowSettings(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
        sentSms: payload,
      );

      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (_) => emit(ValveFlowSuccess(message: "Deviation sent and saved successfully", data: entity)),
      );
=======
      final payload = "$command,${entity.flowDeviation}".replaceAll(RegExp(r'\s+'), '');

      // 1. Send SMS (Publish + Log History)
      final smsResult = await repository.publishValveFlowSms(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        sentSms: payload,
      );

      if (smsResult.isRight()) {
        // 2. Save to database
        final saveResult = await repository.saveValveFlowSettings(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          entity: entity,
        );

        saveResult.fold(
          (failure) => emit(ValveFlowError(message: failure.message)),
          (_) => emit(ValveFlowSuccess(message: "Deviation sent and saved successfully", data: entity)),
        );
      } else {
        smsResult.fold((f) => emit(ValveFlowError(message: f.message)), (_) {});
      }
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
      emit(currentState);
    });

    on<ViewValveFlowEvent>((event, emit) async {
      if (state is! ValveFlowLoaded && state is! ValveFlowSuccess) return;
      final currentState = (state is ValveFlowLoaded)
          ? (state as ValveFlowLoaded)
          : null; // Success state doesn't have deviceId info directly easily, but Loaded does.

      if (currentState == null) return;

      final entity = currentState.entity;

      try {
        final statusMsg = "#VFLOWSET"; // Typical view command or mapping to your requirement
        final cmd = json.encode({"sentSms": statusMsg});

        if (kDebugMode) {
          print("VALVE FLOW VIEW MQTT: Topic: ${currentState.deviceId}, Cmd: $cmd");
        }

        // We can reuse repository.publishMqttCommand if we add it or handle it via a new repository method
        // For now, mirroring Standalone logic by hitting the MQTT publish logic
        await repository.saveValveFlowSettings(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          entity: entity,
          sentSms: statusMsg,
        );

        emit(ValveFlowSuccess(message: event.successMessage, data: entity));
        emit(currentState);
      } catch (e) {
        emit(const ValveFlowError(message: "View status failed."));
      }
    });
  }

  Map<String, dynamic> _parseSmsFormat(String raw) {
    if (raw.isEmpty) return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
  }
}
